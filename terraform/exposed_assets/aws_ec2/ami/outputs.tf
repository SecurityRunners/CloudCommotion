output "exposed_asset" {
  value       = aws_ami.public_ami.id
  description = "Name of the exposed asset"
}
