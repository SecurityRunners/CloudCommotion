provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_name
  location = var.region
}

resource "azurerm_storage_account" "sa" {
  name                     = var.resource_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = var.resource_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "blob"
}

output "public_container_url" {
  value = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/"
}
