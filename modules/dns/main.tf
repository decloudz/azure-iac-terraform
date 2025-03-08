# DNS module - main.tf
# This module manages DNS zones and records

# DNS Zone
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

# External DNS Namespace
resource "kubernetes_namespace" "external_dns" {
  count = var.create_k8s_resources ? 1 : 0

  metadata {
    name = var.external_dns_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}

# External DNS Managed Identity
resource "azurerm_user_assigned_identity" "external_dns_identity" {
  name                = var.external_dns_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

# Grant the External DNS identity DNS Zone Contributor access
resource "azurerm_role_assignment" "external_dns_contributor" {
  scope                = azurerm_dns_zone.dns_zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.external_dns_identity.principal_id
}

# Create a federated identity credential for the external-dns identity
resource "azurerm_federated_identity_credential" "external_dns_federated_identity" {
  count               = var.create_federated_identity ? 1 : 0
  name                = "external-dns-federated-identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.external_dns_identity.id
  subject             = "system:serviceaccount:${var.external_dns_namespace}:external-dns-sa"
}

# Create common DNS records
resource "azurerm_dns_a_record" "wildcard" {
  count               = var.create_wildcard_record && var.app_gateway_public_ip_id != "" ? 1 : 0
  name                = "*"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = var.app_gateway_public_ip_id
} 