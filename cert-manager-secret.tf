# Create a Kubernetes secret for Cert Manager Azure configuration
resource "kubernetes_secret" "cert_manager_azure_config" {
  count      = var.enable_cert_manager ? 1 : 0
  depends_on = [kubernetes_namespace.cert_manager]

  metadata {
    name      = "azure-config-file"
    namespace = var.cert_manager_namespace
  }

  data = {
    "azure.json" = jsonencode({
      tenantId                    = data.azurerm_client_config.current.tenant_id
      subscriptionId              = data.azurerm_subscription.current.subscription_id
      resourceGroup               = var.dns_resource_group_name
      useWorkloadIdentityExtension = true
      userAssignedIdentityID      = azurerm_user_assigned_identity.cert_manager[0].client_id
    })
  }
} 