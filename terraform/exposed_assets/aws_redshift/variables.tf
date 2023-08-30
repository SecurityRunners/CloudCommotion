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
variable "vpc_id" {
  description = "The VPC ID to launch the instance in"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}

variable "allowed_ip" {
  description = "List of IP addresses to allow access to the box"
  type        = string
  default     = "0.0.0.0/0"
}

variable "node_type" {
  description = "The instance type to use for the instance"
  type        = string
  default     = "dc2.large"
}
