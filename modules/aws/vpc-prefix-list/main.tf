
locals {
  max_entries = sum([length(var.cidr_entries), var.extra_entry_slots])
  parsed_cidr_entries = [for x in var.cidr_entries : x if (x.cidr != "0.0.0.0/0" && x.name != "" && x.name != null)]
}

resource "aws_ec2_managed_prefix_list" "this" {
  name           = var.name
  address_family = var.address_family
  max_entries    = local.max_entries

  dynamic "entry" {
    for_each = toset(local.parsed_cidr_entries)
    content {
      cidr        = entry.value.cidr
      description = entry.value.name
    }
  }

  tags = merge(var.tags, {})
}