// App Service module (Chainlit frontend)
resource "azurerm_app_service_plan" "asp" {
  name                = "asp-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}

resource "azurerm_app_service" "main" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    linux_fx_version = var.runtime
  }

  app_settings = var.app_settings
}

output "app_service_default_hostname" {
  value = azurerm_app_service.main.default_site_hostname
}