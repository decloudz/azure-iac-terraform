# Create a User Assigned Managed Identity for Cert Manager
resource "azurerm_user_assigned_identity" "cert_manager" {
  count               = var.enable_cert_manager ? 1 : 0
  name                = var.cert_manager_identity_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

# Create a federated identity credential for Cert Manager
resource "azurerm_federated_identity_credential" "cert_manager" {
  count               = var.enable_cert_manager ? 1 : 0
  name                = var.cert_manager_identity_name
  resource_group_name = azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.cert_manager[0].id
  subject             = "system:serviceaccount:${var.cert_manager_namespace}:cert-manager"

  depends_on = [
    azurerm_user_assigned_identity.cert_manager,
    azurerm_kubernetes_cluster.aks
  ]
}

# Assign Reader role to the Managed Identity on the DNS Resource Group
resource "azurerm_role_assignment" "cert_manager_reader" {
  count                = var.enable_cert_manager ? 1 : 0
  scope                = azurerm_resource_group.dns.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.cert_manager[0].principal_id
}

# Assign DNS Zone Contributor role to the Managed Identity on the DNS Zone
resource "azurerm_role_assignment" "cert_manager_contributor" {
  count                = var.enable_cert_manager ? 1 : 0
  scope                = azurerm_dns_zone.main.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager[0].principal_id
}

# Output the Managed Identity Client ID for use in Kubernetes
output "cert_manager_identity_client_id" {
  description = "The Client ID of the Cert Manager Managed Identity"
  value       = var.enable_cert_manager ? azurerm_user_assigned_identity.cert_manager[0].client_id : null
}

# Output the Managed Identity Resource ID for use in Kubernetes
output "cert_manager_identity_id" {
  description = "The Resource ID of the Cert Manager Managed Identity"
  value       = var.enable_cert_manager ? azurerm_user_assigned_identity.cert_manager[0].id : null
} 