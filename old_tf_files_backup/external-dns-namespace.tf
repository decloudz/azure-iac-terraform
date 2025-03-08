# Create a namespace for External DNS with Workload Identity enabled
resource "kubernetes_namespace" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = var.external_dns_namespace
    
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
} 