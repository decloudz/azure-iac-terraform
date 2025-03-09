# Security module - main.tf
# This module manages security resources including Key Vault, certificates, and identities

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id != "" ? var.tenant_id : "00000000-0000-0000-0000-000000000000" # Use a placeholder when empty
  sku_name            = var.key_vault_sku
  tags                = var.common_tags

  purge_protection_enabled   = var.environment == "prod" ? true : false
  soft_delete_retention_days = 7

  # Network access control
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}

# Grant AKS access to Key Vault
resource "azurerm_key_vault_access_policy" "aks_access" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = var.aks_principal_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}

# Cert Manager Namespace
resource "kubernetes_namespace" "cert_manager" {
  count = var.create_k8s_resources ? 1 : 0
  provider = kubernetes.aks

  metadata {
    name = var.cert_manager_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}

# Cert Manager Managed Identity
resource "azurerm_user_assigned_identity" "cert_manager_identity" {
  name                = var.cert_manager_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

# Grant the Cert Manager identity DNS Zone Contributor access
resource "azurerm_role_assignment" "cert_manager_dns_contributor" {
  count               = var.create_dns_role_assignment ? 1 : 0
  scope                = var.dns_zone_id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager_identity.principal_id
}

# Create a federated identity credential for the cert-manager identity
resource "azurerm_federated_identity_credential" "cert_manager_federated_identity" {
  count               = var.create_federated_identity ? 1 : 0
  name                = "cert-manager-federated-identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.cert_manager_identity.id
  subject             = "system:serviceaccount:${var.cert_manager_namespace}:cert-manager-sa"
} 