output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}