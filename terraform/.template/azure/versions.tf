terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
