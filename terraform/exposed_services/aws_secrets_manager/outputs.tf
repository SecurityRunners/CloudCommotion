output "exposed_asset" {
  value       = aws_secretsmanager_secret.secret.arn
  description = "Name of the exposed asset"
}
