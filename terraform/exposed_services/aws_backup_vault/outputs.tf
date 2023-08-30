output "exposed_asset" {
  value       = aws_backup_vault.vault.arn
  description = "Name of the exposed asset"
}
