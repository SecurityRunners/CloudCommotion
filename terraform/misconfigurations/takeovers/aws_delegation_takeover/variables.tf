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

# Optional variables
variable "tags" {
  description = "Organization tagging strategy but should keep Creator tag for discovery later."
  type        = map(string)
  default = {
    "Creator" = "CloudCommotion"
  }
}

# Custom variables
variable "parent_domain" {
  description = "The parent domain name."
  type        = string
}

variable "parent_zone_id" {
  description = "The Route53 Zone ID for the parent domain."
  type        = string
}
