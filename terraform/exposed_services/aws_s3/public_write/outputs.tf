output "exposed_asset" {
  value       = aws_s3_bucket.public_bucket.id
  description = "Name of the exposed asset"
}
