output "exposed_asset" {
  value       = aws_ebs_snapshot.public_snapshot.id
  description = "Name of the exposed asset"
}
