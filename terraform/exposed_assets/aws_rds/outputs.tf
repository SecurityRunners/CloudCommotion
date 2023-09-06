output "exposed_asset" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "Name of the exposed asset"
}
