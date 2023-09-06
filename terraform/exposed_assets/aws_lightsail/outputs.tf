output "exposed_asset" {
  value       = "http://${aws_lightsail_instance.lightsail.public_ip_address}"
  description = "Name of the exposed asset"
}
