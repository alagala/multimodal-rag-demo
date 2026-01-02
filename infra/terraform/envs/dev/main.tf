terraform {
  required_version = ">= 1.2"
}

provider "azurerm" {
  features = {}
}

module "vnet" {
  source = "../modules/vnet"

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "storage" {
  source = "../modules/storage"

  resource_group_name = var.resource_group_name
  location            = var.location
  storage_account_name = "chdemo${random_id.storage_suffix.hex}"
}

# NOTE: additional modules for search, functions, app_service, keyvault will be added as they're implemented
