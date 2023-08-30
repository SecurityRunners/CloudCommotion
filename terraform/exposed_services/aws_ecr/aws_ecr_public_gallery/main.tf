provider "aws" {
  region = var.region
}

resource "aws_ecrpublic_repository" "ecrpublic" {
  repository_name = var.resource_name

  catalog_data {
    description = var.sensitive_content
  }

  tags = var.tags
}
