output "exposed_asset" {
  value       = aws_lb.opensearch.dns_name
  description = "Name of the exposed asset"
}
