output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.name
}

output "log_analytics_workspace_primary_key" {
  description = "Primary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "app_insights_app_id" {
  description = "App ID for Application Insights"
  value       = azurerm_application_insights.app_insights.app_id
}

output "action_group_id" {
  description = "ID of the Action Group for critical alerts"
  value       = azurerm_monitor_action_group.critical_alerts.id
} 