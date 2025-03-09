variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name, such as 'dev', 'test', 'prod'"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.25.6"
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 2
}

variable "aks_max_pods" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 30
}

variable "aks_admin_username" {
  description = "Admin username for AKS nodes"
  type        = string
  default     = "azureuser"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for AKS"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace for AKS monitoring"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for AKS nodes"
  type        = string
}

variable "acr_id" {
  description = "ID of the Azure Container Registry"
  type        = string
  default     = ""
}

variable "admin_group_object_ids" {
  description = "Object IDs of Azure AD groups with admin access to the cluster"
  type        = list(string)
  default     = []
}

variable "network_plugin" {
  description = "Network plugin to use for Kubernetes networking (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy to use for Kubernetes networking (azure or calico)"
  type        = string
  default     = "calico"
}

variable "service_cidr" {
  description = "CIDR notation IP range from which Kubernetes service IPs are assigned"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by kube-dns"
  type        = string
  default     = "172.16.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge network"
  type        = string
  default     = "172.17.0.1/16"
}

variable "load_balancer_sku" {
  description = "SKU of the load balancer to use with AKS (basic or standard)"
  type        = string
  default     = "standard"
} 