// Storage module (skeleton): create storage account and upload/processed containers
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "upload" {
  name                  = var.upload_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = var.processed_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Private endpoint for the storage account (requires subnet id)
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-${azurerm_storage_account.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.main.name}"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "upload_container" {
  value = azurerm_storage_container.upload.name
}

output "processed_container" {
  value = azurerm_storage_container.processed.name
}