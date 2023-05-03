locals {
  trimmed_bucket_path = trimsuffix(var.bucket_path, "/")
  resources = [
    "arn:aws:s3:::${var.bucket_name}${local.trimmed_bucket_path}/*",
    "arn:aws:s3:::${var.bucket_name}${local.trimmed_bucket_path}",
  ]
  action_lists = {
    "list" = [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets",
      ]
    "read" = [
        "s3:GetObject",
        "s3:GetObjectAttributes",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAttributes",
        "s3:GetLifecycleConfiguration",
        "s3:GetObjectAcl",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectTagging",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectRetention",
      ]
    "write" = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl",
        "s3:PutLifecycleConfiguration",
        "s3:PutObjectTagging",
        "s3:PutObjectRetention",
      ]
    "delete" = [
        "s3:DeleteObject",
        "s3:DeleteObjectTagging",
        "s3:DeleteObjectVersion",
      ]
    "non-resource-specific" = [
        "s3:ListAllMyBuckets"
      ]
  }

  actions_to_apply = concat(
      var.allow_list ? local.action_lists["list"] : [],
      var.allow_read ? local.action_lists["read"] : [],
      var.allow_write ? local.action_lists["write"] : [],
      var.allow_delete ? local.action_lists["delete"] : [],
    )

  all_resources_actions = setintersection( toset(local.actions_to_apply), toset(local.action_lists["non-resource-specific"]) )
  specific_resource_actions = setsubtract(toset(local.actions_to_apply), toset(local.all_resources_actions))
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each    = length(local.specific_resource_actions)>0 ? [1] : []
    content {
      sid       = "S3crud"
      effect    = "Allow"

      resources = local.resources

      actions   = local.specific_resource_actions
    }
  }

  dynamic "statement" {
    for_each    = length(local.all_resources_actions)>0 ? [1] : []
    content {
      sid       = "AllResources"
      effect    = "Allow"

      resources = ["*"]

      actions   = local.all_resources_actions
    }
  }

  dynamic "statement" {
    for_each    = length(var.allow_assumption_arns)>0 ? [1] : []
    content {
      sid       = "AssumeRole"
      effect    = "Allow"
      resources = var.allow_assumption_arns
      actions   = ["sts:AssumeRole"]
    }
  }
}

resource "aws_iam_policy" "this" {
  description  = ""
  name         = var.policy_name
  name_prefix  = null
  path         = "/"
  policy       = data.aws_iam_policy_document.this.json
  tags         = merge(var.tags, {
    Name = var.policy_name
  })
}