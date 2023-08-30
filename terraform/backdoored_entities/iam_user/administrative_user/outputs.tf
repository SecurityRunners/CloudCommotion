output "exposed_asset" {
  value       = aws_iam_user.admin_user.arn
  description = "Name of the administrator IAM user"
}
