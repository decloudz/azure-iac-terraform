# Networking outputs
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.networking.subnet_ids
}

# Kubernetes outputs
output "aks_id" {
  description = "ID of the AKS cluster"
  value       = local.should_create_resources ? module.kubernetes[0].aks_id : null
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = local.should_create_resources ? module.kubernetes[0].aks_name : null
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = local.should_create_resources ? module.kubernetes[0].aks_fqdn : null
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = local.should_create_resources ? module.kubernetes[0].kube_config : null
  sensitive   = true
}

# Database outputs
output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = local.should_create_resources ? module.database[0].postgresql_server_fqdn : null
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = local.should_create_resources ? module.database[0].postgresql_database_name : null
}

# Security outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = local.should_create_resources ? module.security[0].key_vault_id : null
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = local.should_create_resources ? module.security[0].key_vault_uri : null
}

# Monitoring outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.monitoring.app_insights_instrumentation_key
  sensitive   = true
}

# DNS outputs
output "dns_zone_name" {
  description = "Name of the DNS zone"
  value       = local.should_create_resources ? module.dns[0].dns_zone_name : null
}

output "name_servers" {
  description = "Name servers for the DNS zone"
  value       = local.should_create_resources ? module.dns[0].name_servers : null
} 