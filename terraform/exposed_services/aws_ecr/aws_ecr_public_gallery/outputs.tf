output "exposed_asset" {
  value       = replace(aws_ecrpublic_repository.ecrpublic.repository_uri, "public.ecr.aws", "https://gallery.ecr.aws")
  description = "Name of the exposed asset"
}
