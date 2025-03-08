# Helm release for External DNS
resource "helm_release" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  depends_on = [
    azurerm_role_assignment.external_dns_contributor,
    azurerm_role_assignment.external_dns_reader,
    azurerm_federated_identity_credential.external_dns,
    kubernetes_namespace.external_dns,
    kubernetes_secret.azure_config_file,
    azurerm_kubernetes_cluster.aks
  ]

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = var.external_dns_namespace
  create_namespace = true
  version          = var.external_dns_chart_version

  set {
    name  = "provider"
    value = "azure"
  }

  # Use the azure-config-file secret
  set {
    name  = "extraVolumes[0].name"
    value = "azure-config-file"
  }

  set {
    name  = "extraVolumes[0].secret.secretName"
    value = "azure-config-file"
  }

  set {
    name  = "extraVolumeMounts[0].name"
    value = "azure-config-file"
  }

  set {
    name  = "extraVolumeMounts[0].mountPath"
    value = "/etc/kubernetes"
  }

  set {
    name  = "extraVolumeMounts[0].readOnly"
    value = "true"
  }

  # Workload Identity settings
  set {
    name  = "serviceAccount.annotations.azure\\.workload\\.identity/client-id"
    value = azurerm_user_assigned_identity.external_dns[0].client_id
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "domainFilters[0]"
    value = var.dns_zone_name
  }

  set {
    name  = "txtOwnerId"
    value = var.kubernetes_cluster_name
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "interval"
    value = "1m"
  }

  set {
    name  = "logLevel"
    value = "info"
  }
} 