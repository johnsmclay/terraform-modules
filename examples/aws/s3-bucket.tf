locals {
	s3_naming_prefix = "coolco"
	environment = "prod"
	tags = {
		environment = local.environment
		department = "marketing"
	}
}

module "data_export_s3_bucket" {
  source                 = "git::git@github.com:johnsmclay/terraform-modules.git//modules/aws/s3-bucket?ref=tags/0.0.1"
  bucket_name            = "${local.s3_naming_prefix}-${local.environment}-marketing-junk"
  canned_acl             = "private"
  sse_on_by_default      = true
  require_sse_header     = false
  tags                   = merge(local.tags, {})
}