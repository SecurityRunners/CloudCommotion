output "exposed_asset" {
  value       = aws_lb.jenkins.dns_name
  description = "Name of the exposed asset"
}
