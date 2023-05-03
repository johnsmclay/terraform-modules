locals {
  share_use_existing = (var.existing_share_arn == null || var.existing_share_arn == "") ? false : true
  share_enabled = length(var.share_to_principals) > 0 || local.share_use_existing
  share_arn = local.share_enabled ? (local.share_use_existing ? var.existing_share_arn : aws_ram_resource_share.this[0].arn) : null
  share_prin_assoc_list = local.share_enabled ? var.share_to_principals : []
}

resource "aws_ram_resource_share" "this" {
  count                     = local.share_use_existing ? 0 : 1
  name                      = "${var.name}_prefix_list_resource_share"
  allow_external_principals = true
  permission_arns           = [var.share_permissions_arn]
}

resource "aws_ram_principal_association" "this" {
  for_each           = toset(local.share_prin_assoc_list)
  principal          = each.value
  resource_share_arn = local.share_arn
}