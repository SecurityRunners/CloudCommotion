output "exposed_asset" {
  value       = aws_instance.ssh.public_ip
  description = "Name of the exposed asset"
}
