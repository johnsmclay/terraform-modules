# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "bucket_name" {
  description = "Name of the s3 bucket. Must be globally unique."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "with_policy" {
  description = "If set to `true`, the bucket will be created with a bucket policy. Required for tls and encryption requirements."
  type        = bool
  default     = true
}

variable "require_tls" {
  description = "If set to `true`, the bucket will require transport security (SSL/TLS). Requires a bucket policy ('with_policy'=true)."
  type        = bool
  default     = true
}

variable "require_sse_header" {
  description = "If set to `true`, the bucket will require any new objects to be written with SSE turned on. Requires a bucket policy ('with_policy'=true)."
  type        = bool
  default     = true
}

variable "sse_on_by_default" {
  description = "If set to `true`, the bucket will require any new objects to be written with SSE turned on. Requires a bucket policy ('with_policy'=true)."
  type        = bool
  default     = true
}

variable "name_add_account_id_prefix" {
  description = "If set to true, Adds prefix of aws account id to the bucket name."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to set on the bucket."
  type        = map(string)
  default     = {}
}

variable "with_versioning" {
  description = "If set to `true`, the bucket will be created with versioning enabled."
  type        = bool
  default     = false
}

variable "lifecycle_abort_multipart_days" {
  description = "If set, lifecycle rule will transition current objects to IA after X days"
  type        = number
  default     = 2
}

variable "lifecycle_transition_ia_days" {
  description = "If set, lifecycle rule will transition current objects to IA after X days"
  type        = number
  default     = 30
}

variable "lifecycle_expire_current_days" {
  description = "If set, lifecycle rule will transition current objects to IA after X days"
  type        = number
  default     = null
}

variable "lifecycle_delete_expired_days" {
  description = "If set, lifecycle rule will mark old versions of objects for deletion after X days"
  type        = number
  default     = 180
}

## TODO: Logging untested 
# variable "logging_path" {
#   description = "If set, logging will be enabled and sent to that S3 location. Pattern: '{bucket}/{path}'"
#   type        = string
#   default     = null
# }

variable "sse_algorithm" {
  description = "If set to `true`, the bucket will be created with versioning enabled."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"],var.sse_algorithm)
    error_message = "Specified canned ACL must be supported (All but 'public-read-write')."
  }
}

variable "sse_kms_master_key_arn" {
  description = "If using SSE='aws:kms', allows you to specify the KMS key to use instead of the default one for S3."
  type        = string
  default     = null
}

variable "canned_acl" {
  description = "The canned ACL to use for the bucket. See: https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl"
  type        = string
  default     = "private"
  validation {
    condition     = contains(
        [
          "private", "public-read", "authenticated-read",
          "log-delivery-write", "aws-exec-read",
          "bucket-owner-read", "bucket-owner-full-control"
        ],
        var.canned_acl
      )
    error_message = "Specified canned ACL must be supported (All but 'public-read-write')."
  }
}