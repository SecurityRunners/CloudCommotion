output "exposed_asset" {
  value       = aws_ecr_repository.public_repo.repository_url
  description = "Name of the exposed asset"
}
