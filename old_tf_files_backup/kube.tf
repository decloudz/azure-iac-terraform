# Get the AKS cluster details
data "azurerm_kubernetes_cluster" "cluster" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# NOTE: To make this configuration work, you need to install the kubelogin CLI tool:
# For macOS: brew install Azure/kubelogin/kubelogin
# For Windows: az aks install-cli
# For Linux: https://github.com/Azure/kubelogin

# Configure the Kubernetes provider using AKS credentials
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
  
  # Use kubelogin to support AKS authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630", # AAD Server ID
      "--client-id",
      var.sp-client-id,
      "--client-secret",
      var.sp-client-secret
    ]
  }
}

# Configure the Helm provider using the same AKS credentials
provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
    
    # Use kubelogin to support AKS authentication
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--login",
        "spn",
        "--environment",
        "AzurePublicCloud",
        "--tenant-id",
        data.azurerm_client_config.current.tenant_id,
        "--server-id",
        "6dae42f8-4368-4678-94ff-3960e28e3630", # AAD Server ID
        "--client-id",
        var.sp-client-id,
        "--client-secret",
        var.sp-client-secret
      ]
    }
  }
}

# Configure the kubectl provider for kubernetes_manifest resources
provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
  
  # Use kubelogin to support AKS authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--server-id", 
      "6dae42f8-4368-4678-94ff-3960e28e3630", # AAD Server ID
      "--client-id",
      var.sp-client-id,
      "--client-secret",
      var.sp-client-secret
    ]
  }
}