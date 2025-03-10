# Kubernetes module - main.tf
# This module manages AKS cluster and related resources

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project}-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  tags                = var.common_tags

  default_node_pool {
    name                = "default"
    vm_size             = var.aks_vm_size
    node_count          = var.aks_node_count
    max_pods            = var.aks_max_pods
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    os_disk_size_gb     = 100
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    network_policy    = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  linux_profile {
    admin_username = var.aks_admin_username
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  # Monitor configuration
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}

# AKS ACR integration
resource "azurerm_role_assignment" "aks_acr_pull" {
  count               = var.acr_id != "" ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
} 