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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
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

variable "file_name" {
  description = "Name of the file to create in the repository"
  type        = string
  default     = "sensitive.txt"
}
