output "exposed_asset" {
  value       = aws_iam_role.exposed_asset.arn
  description = "Backdoored IAM role ARN"
}
