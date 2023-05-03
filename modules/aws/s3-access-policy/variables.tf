# Variables you can pass into the module to make it dynamic.

variable "bucket_name" {
  description = "Name of the s3 bucket. Must be globally unique."
  type        = string
}

variable "policy_name" {
  description = "Name of the s3 IAM policy to create. Must be env unique."
  type        = string
}

variable "bucket_path" {
  type        = string
  description = "ARN of S3 path"
  # No default, it is best they specify rather than defaulting to the whole bucket.
}

variable "allow_aws_identifiers" {
  type        = list(string)
  description = "List of ARNs of accounts to allow"
  default = []
}

variable "allow_assumption_arns" {
  type        = list(string)
  description = "List of ARNs of roles to allow assumption in this policy"
  default = []
}

variable "allow_list" {
  type        = bool
  description = "Allow listing of items from the path"
  # listing is easily forgotten and rarely forbidden when allowing other permissions,
  # so defaulting to allow.
  default     = true
}

variable "allow_read" {
  type        = bool
  description = "Allow reading of items from the path"
  default     = false
}

variable "allow_write" {
  type        = bool
  description = "Allow writing items to the path"
  default     = false
}

variable "allow_delete" {
  type        = bool
  description = "Allow deletion of items from the path"
  default     = false
}

variable "tags" {
  description = "Tags to set on the policies."
  type        = map(string)
  default     = {}
}