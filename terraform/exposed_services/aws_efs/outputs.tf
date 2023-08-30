output "exposed_asset" {
  value       = aws_efs_file_system.fs.arn
  description = "Name of the exposed asset"
}
