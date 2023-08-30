output "exposed_asset" {
  value       = aws_redshift_cluster.cluster.endpoint
  description = "Name of the exposed asset"
}
