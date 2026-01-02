// Azure Cognitive Search (skeleton)
resource "azurerm_search_service" "main" {
  name                = var.search_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
}

# Private endpoint for Search (requires subnet id)
resource "azurerm_private_endpoint" "search_pe" {
  name                = "pe-${azurerm_search_service.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_search_service.main.name}"
    private_connection_resource_id = azurerm_search_service.main.id
    is_manual_connection           = false
  }
}

output "search_service_id" {
  value = azurerm_search_service.main.id
}

output "search_service_endpoint" {
  value = azurerm_search_service.main.endpoint
}