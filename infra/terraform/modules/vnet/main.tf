// VNet module: creates a VNet and subnets for private endpoints
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.private_subnet_prefixes
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}