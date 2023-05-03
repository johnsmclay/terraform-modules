output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

## TODO: Logging untested 
# output "logging_target_bucket" {
#   value = local.with_logging ? aws_s3_bucket_logging.this[0].target_bucket : null
# }

# output "logging_target_prefix" {
#   value = local.with_logging ? aws_s3_bucket_logging.this[0].target_prefix : null
# }