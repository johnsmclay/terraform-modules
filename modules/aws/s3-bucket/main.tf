# ---------------------------------------------------------------------------------------------------------------------
# LOCALS
# Used to represent any data that requires complex expressions/interpolations
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

## TODO: Logging untested
# data "aws_s3_bucket" "logging_bucket" {
#    count            = local.with_logging ? 1 : 0
#    bucket           = local.logging_bucket_name
# }

locals {
  path_separator    = "/"
  aws_account_id    = data.aws_caller_identity.current.account_id
  versioning_status = var.with_versioning ? "Enabled" : "Disabled"
  tags              = merge(var.tags, {})
  enable_ted_rule   = var.lifecycle_transition_ia_days != null || var.lifecycle_expire_current_days != null || var.lifecycle_delete_expired_days != null

  # Naming Stuff
  name_prefix       = var.name_add_account_id_prefix ? "${local.aws_account_id}-" : ""
  bucket_name       = "${local.name_prefix}${var.bucket_name}"

  # Logging Stuff
  ## TODO: Logging untested
  # with_logging      = var.logging_path != null ? true : false
  # logging_parts     = local.with_logging ? split(local.path_separator, var.logging_path) : []
  # logging_bucket_name = local.with_logging ? local.logging_parts[0] : ""
  # logging_prefix    = join(local.path_separator,[for x in local.logging_parts : x if x != local.logging_bucket_name])
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

# Deploy and configure test S3 bucket with versioning and access log
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = merge(local.tags, {
    Name        = local.bucket_name
  })

  
  # See: https://registry.terraform.io/providers/hashicorp/aws/3.75.2/docs/resources/s3_bucket
  # Specifically the "NOTE on S3 Bucket {XXX} Configuration" sections.
  # In 3.75.2, you could define several items inside of aws_s3_bucket (dep) OR in separate objects (new)
  # If you used the new model, you have to tell the aws_s3_bucket to ignore it's own versions of the 
  #  same or they will conflict.
  # This changes in AWS provider >= 4.0.0 (but we should go directly to 4.9.0)
  # See also: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade?product_intent=terraform
  lifecycle {
    ignore_changes = [
      lifecycle_rule,
      server_side_encryption_configuration,
      grant,
    ]
  }
}

# Configure bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = local.versioning_status
  }
}

# Configure bucket canned ACL
resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.canned_acl
}



# Configure bucket public access policies
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure bucket object lifecycle policies
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this]
  bucket     = aws_s3_bucket.this.id

  # Everything is downgraded after specified days
  dynamic "rule" {
    for_each    = local.enable_ted_rule ? [1] : []
    content {
      id = "transition_expire_delete"
      filter {}
      dynamic "transition" {
        for_each    = var.lifecycle_transition_ia_days != null ? [1] : []
        content {
          days          = var.lifecycle_transition_ia_days
          storage_class = "STANDARD_IA"
        }
      }
      dynamic "expiration" {
        for_each    = var.lifecycle_expire_current_days != null ? [1] : []
        content {
          days = var.lifecycle_expire_current_days
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each    = var.lifecycle_delete_expired_days != null ? [1] : []
        content {
          noncurrent_days = var.lifecycle_delete_expired_days
        }
      }
      status = "Enabled"
    }
  }

  # Abort multi-part uploads 1 day later if not finished
  dynamic "rule" {
    for_each    = var.lifecycle_abort_multipart_days != null ? [1] : []
    content {
      id = "abort_multipart"
      filter {}
      abort_incomplete_multipart_upload {
        days_after_initiation = var.lifecycle_abort_multipart_days
      }
      status = "Enabled"
    }
  }

  # dynamic "rule" {
  #   for_each    = var.require_tls ? [1] : []
  #   content {
      
  #   }
  # }
}

# Configure bucket access policies
resource "aws_s3_bucket_policy" "bucket_access_policy" {
  count  = var.with_policy ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
      kms_master_key_id = var.sse_kms_master_key_arn
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  dynamic "statement" {
    for_each    = var.require_tls ? [1] : []
    content {
      effect = "Deny"
      principals {
        identifiers = ["*"]
        type        = "AWS"
      }
      actions   = ["*"]
      resources = ["${aws_s3_bucket.this.arn}/*"]
      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }

  dynamic "statement" {
    for_each    = var.require_sse_header ? [1] : []
    content {
      effect = "Deny"
      principals {
        identifiers = ["*"]
        type        = "AWS"
      }
      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.this.arn}/*"]
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption"
        values   = [var.sse_algorithm]
      }
    }
  }
}

# Configure bucket access logging
## TODO: Logging untested 
# resource "aws_s3_bucket_logging" "this" {
#   count         = local.with_logging ? 1 : 0
#   bucket        = aws_s3_bucket.this.id
#   target_bucket = data.aws_s3_bucket.logging_bucket[0].id
#   target_prefix = "${local.logging_prefix}/${local.bucket_name}/"
# }