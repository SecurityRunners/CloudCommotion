output "exposed_asset" {
  value       = aws_opensearch_domain.domain.endpoint
  description = "Name of the exposed asset"
}
