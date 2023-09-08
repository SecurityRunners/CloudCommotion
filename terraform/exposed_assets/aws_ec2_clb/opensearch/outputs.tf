output "exposed_asset" {
  value       = aws_elb.opensearch.dns_name
  description = "Name of the exposed asset"
}
