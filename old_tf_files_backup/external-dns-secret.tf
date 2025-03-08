# Create a Kubernetes secret for External DNS Azure configuration
resource "kubernetes_secret" "azure_config_file" {
  count      = var.enable_external_dns ? 1 : 0
  depends_on = [kubernetes_namespace.external_dns]

  metadata {
    name      = "azure-config-file"
    namespace = var.external_dns_namespace
  }

  data = {
    "azure.json" = jsonencode({
      tenantId                    = data.azurerm_client_config.current.tenant_id
      subscriptionId              = data.azurerm_subscription.current.subscription_id
      resourceGroup               = var.dns_resource_group_name
      useWorkloadIdentityExtension = true
      userAssignedIdentityID      = azurerm_user_assigned_identity.external_dns[0].client_id
    })
  }
} 