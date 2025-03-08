# Monitoring module - main.tf
# This module manages monitoring resources including Log Analytics workspace

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_in_days
  tags                = var.common_tags
}

# Enable Container Insights for AKS
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.common_tags
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = var.common_tags
}

# Alert rules
resource "azurerm_monitor_action_group" "critical_alerts" {
  name                = "ag-critical-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "critical"
  tags                = var.common_tags

  # Only create email receivers if emails are provided
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
} 