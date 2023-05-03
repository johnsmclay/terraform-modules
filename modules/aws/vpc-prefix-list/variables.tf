variable "name" {
  description = "Name of the CIDR list"
  type        = string
}

variable "address_family" {
  description = "IPv4 (default) / IPv6 "
  type        = string
  default     = "IPv4"
}

variable "cidr_entries" {
  description = "name -> cidr map of entries for the list.  '0.0.0.0/0' is not allowed."
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "Additional tags to set on the list."
  type        = map(string)
  default     = {}
}

variable "extra_entry_slots" {
  description = "IDK, but if you wanted to do extras for some reason."
  type        = number
  default     = 0
}

variable "share_to_principals" {
  description = <<EOT
    Mixed array of one or more of the following:
    Org ARN: `arn:aws:organizations::<12-digit-org_master_account_ID>:organization/o-<org-ID>`
    AWS Account ID: `111111111111` (12-digit)
    OU ARN: `arn:aws:organizations::<12-digit-org_master_account_ID>:ou/o-<org-ID>/ou-<ou-ID>`
  EOT
  type        = list(string)
  default     = []
}

variable "existing_share_arn" {
  description = "If you want to add this list to an existing share instead of making a new one."
  type        = string
  default     = ""
}

variable "share_permissions_arn" {
  description = <<EOT
  If you want to use something other than the default permission set (read-only).
  This is only the case if the share is being created here, not for existing shares.
  EOT
  type        = string
  default     = "arn:aws:ram::aws:permission/AWSRAMDefaultPermissionPrefixList"
}