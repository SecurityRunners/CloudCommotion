output "exposed_asset" {
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
  description = "Name of the exposed asset"
}
