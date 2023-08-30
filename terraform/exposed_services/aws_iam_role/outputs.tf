output "exposed_asset" {
  value       = aws_iam_role.public_role.arn
  description = "Name of the exposed asset"
}
