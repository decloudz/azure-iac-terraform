# Create a namespace for Cert Manager with Workload Identity enabled
resource "kubernetes_namespace" "cert_manager" {
  count      = var.enable_cert_manager ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = var.cert_manager_namespace
    
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
} 