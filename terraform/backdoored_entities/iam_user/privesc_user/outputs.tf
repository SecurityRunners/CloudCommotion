output "exposed_asset" {
  value       = aws_iam_user.exposed_asset.arn
  description = "Name of the administrator IAM user"
}
