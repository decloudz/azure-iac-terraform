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
  value       = module.kubernetes.aks_id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = module.kubernetes.aks_name
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.kubernetes.aks_fqdn
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = module.kubernetes.kube_config
  sensitive   = true
}

# Database outputs
output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.database.postgresql_server_fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.database.postgresql_database_name
}

# Security outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
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
  value       = module.dns.dns_zone_name
}

output "name_servers" {
  description = "Name servers for the DNS zone"
  value       = module.dns.name_servers
} 