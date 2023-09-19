# Global variables
variable "resource_name" {
  description = "Convincing bucket name for the organization"
  type        = string
}

variable "sensitive_content" {
  description = "Content of the sensitive file to reach out to an appropriate contact."
  type        = string
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

# Custom variables
variable "github_token" {
  description = "GitHub API token"
  type        = string
}

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
}
