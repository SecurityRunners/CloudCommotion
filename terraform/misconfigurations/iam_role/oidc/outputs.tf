output "exposed_asset" {
  value       = aws_iam_role.role.arn
  description = "Name of the exposed asset"
}
