// Azure Function App (skeleton)
# Note: Function App requires a storage account for functions' runtime storage and optionally an App Service Plan
resource "azurerm_storage_account" "functions_storage" {
  name                     = var.functions_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "azurerm_app_service_plan" "asp" {
  name                = "asp-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "main" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.functions_storage.name
  storage_account_access_key = azurerm_storage_account.functions_storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(var.app_settings, {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "WEBSITE_RUN_FROM_PACKAGE" = var.package_url
  })

  # VNet Integration & outbound access: configure as needed (placeholder)
}

# Private endpoint for Function App if needed for private access to functions
resource "azurerm_private_endpoint" "functions_pe" {
  name                = "pe-${azurerm_function_app.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_function_app.main.name}"
    private_connection_resource_id = azurerm_function_app.main.id
    is_manual_connection           = false
  }
}

output "function_app_id" {
  value = azurerm_function_app.main.id
}

output "function_app_default_hostname" {
  value = azurerm_function_app.main.default_hostname
}