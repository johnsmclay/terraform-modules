locals {
  vpc_prefix_lists = {
    private = ["10.220.1.0/24","10.220.3.0/24"]
    public = ["10.220.2.0/24"]
  }
  share_principals = [
    "arn:aws:organizations::111111111111:organization/o-zijow2dcvb",
    "222222222222"
  ]
}

###  Just one, with a share ################
module "vpc_cidr_lists" {
  source              = "git::git@github.com:johnsmclay/terraform-modules.git//modules/aws/vpc-prefix-list?ref=tags/0.0.1"
  name                = "private_subnets"
  cidr_entries        = [for x in local.vpc_prefix_lists["private"] : {name = "TF-private-subnet", cidr = x}]
  share_to_principals = local.share_principals
}


###  Multiple lists, with a central share ################

resource "aws_ram_resource_share" "inter_account_share" {
  name                      = "inter_account_share"
  allow_external_principals = false
  # You could specify the ARN of a permission set, but it has one by default.
  # For example, for a prefix list, the default perms are list the objects and get prefix values.
  # On prefix lists, that's all we'd want to do anyway.
}

resource "aws_ram_principal_association" "inter_account_share_invite" {
  for_each           = toset(local.share_principals)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.inter_account_share.arn
}

module "vpc_cidr_lists" {
  source              = "git::git@github.com:johnsmclay/terraform-modules.git//modules/aws/vpc-prefix-list?ref=tags/0.0.1"
  for_each            = local.vpc_prefix_lists
  name                = "vpc_${each.key}_subnets"
  cidr_entries        = [for x in each.value : {name = "TF-${each.key}-subnet", cidr = x}]
  share_to_principals = local.share_principals
  existing_share_arn  = aws_ram_resource_share.inter_account_share.arn
}



### Accepting a share ################

# On reciever side
resource "aws_ram_resource_share_accepter" "receiver_accept" {
  share_arn = "<share_arn output from source>"
}