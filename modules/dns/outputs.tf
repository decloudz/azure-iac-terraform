output "dns_zone_id" {
  description = "ID of the DNS zone"
  value       = azurerm_dns_zone.dns_zone.id
}

output "dns_zone_name" {
  description = "Name of the DNS zone"
  value       = azurerm_dns_zone.dns_zone.name
}

output "name_servers" {
  description = "Name servers for the DNS zone"
  value       = azurerm_dns_zone.dns_zone.name_servers
}

output "external_dns_identity_id" {
  description = "ID of the External DNS managed identity"
  value       = azurerm_user_assigned_identity.external_dns_identity.id
}

output "external_dns_identity_principal_id" {
  description = "Principal ID of the External DNS managed identity"
  value       = azurerm_user_assigned_identity.external_dns_identity.principal_id
}

output "external_dns_identity_client_id" {
  description = "Client ID of the External DNS managed identity"
  value       = azurerm_user_assigned_identity.external_dns_identity.client_id
} 