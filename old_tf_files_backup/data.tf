# Get details of the current Azure subscription
data "azurerm_subscription" "current" {}

# Data source for client configuration including current tenant ID
data "azurerm_client_config" "current" {}

# Data source for existing resource group
data "azurerm_resource_group" "existing" {
  name = azurerm_resource_group.aks.name

  depends_on = [
    azurerm_resource_group.aks
  ]
} 