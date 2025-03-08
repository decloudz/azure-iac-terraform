output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "cert_manager_identity_id" {
  description = "ID of the Cert Manager managed identity"
  value       = azurerm_user_assigned_identity.cert_manager_identity.id
}

output "cert_manager_identity_principal_id" {
  description = "Principal ID of the Cert Manager managed identity"
  value       = azurerm_user_assigned_identity.cert_manager_identity.principal_id
}

output "cert_manager_identity_client_id" {
  description = "Client ID of the Cert Manager managed identity"
  value       = azurerm_user_assigned_identity.cert_manager_identity.client_id
} 