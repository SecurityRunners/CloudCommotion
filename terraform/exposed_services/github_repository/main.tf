provider "github" {
  owner        = var.organization_name
  token        = var.github_token
}

resource "github_repository" "repo" {
  name        = var.resource_name
  description = "Created through cloudcommotion terraform"
  visibility  = "public"
}

resource "github_repository_file" "flag" {
  repository = github_repository.repo.name
  file       = var.file_name
  content    = var.sensitive_content
}
