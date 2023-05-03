# Put anything you want to be available to other modules/code outside this module.
# Might be informational like generated IDs, might be debug info.

output "policy" {
  description = "The resulting policy info (name & ARN)"
  value       = {
    name       = aws_iam_policy.this.name
    arn        = aws_iam_policy.this.arn
  }
}