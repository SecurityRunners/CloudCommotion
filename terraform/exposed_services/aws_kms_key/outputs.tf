output "exposed_asset" {
  value       = aws_kms_key.public_key.arn
  description = "Name of the exposed asset"
}
