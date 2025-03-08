# Create a ClusterIssuer for Let's Encrypt with DNS validation
resource "kubectl_manifest" "cluster_issuer" {
  count      = var.enable_cert_manager ? 1 : 0
  depends_on = [
    kubernetes_namespace.cert_manager,
    kubernetes_secret.cert_manager_azure_config,
    azurerm_federated_identity_credential.cert_manager
  ]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.cert_manager_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        azureDNS:
          resourceGroupName: ${var.dns_resource_group_name}
          subscriptionID: ${data.azurerm_subscription.current.subscription_id}
          hostedZoneName: ${var.dns_zone_name}
          environment: AzurePublicCloud
          managedIdentity:
            clientID: ${azurerm_user_assigned_identity.cert_manager[0].client_id}
YAML
} 