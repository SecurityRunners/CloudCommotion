output "exposed_asset" {
  value       = aws_glacier_vault.archive.arn
  description = "Name of the exposed asset"
}
