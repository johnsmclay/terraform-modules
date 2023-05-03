
output "list_id" {
  value = aws_ec2_managed_prefix_list.this.id
}

output "list_name" {
  value = aws_ec2_managed_prefix_list.this.name
}

output "list_version" {
  value = aws_ec2_managed_prefix_list.this.version
}

output "list_arn" {
  value = aws_ec2_managed_prefix_list.this.arn
}

output "share_arn" {
  value = local.share_arn
}