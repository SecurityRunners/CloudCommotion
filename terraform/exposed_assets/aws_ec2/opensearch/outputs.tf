output "exposed_asset" {
  value       = "curl -X GET https://${aws_instance.opensearch.public_ip}:9200 -ku admin:admin"
  description = "Name of the exposed asset"
}
