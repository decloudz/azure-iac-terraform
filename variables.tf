# Project Information
variable "project" {
  description = "Project name"
  type        = string
  default     = "gcse-prime-edm"
}

variable "environment" {
  description = "Environment name, such as 'dev', 'test', 'prod'"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "DevOps Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT-12345"
}

# Add variables for authentication
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
  default     = null
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
  default     = null
}

# Add a test mode variable
variable "test_mode" {
  description = "Run in test mode with dummy credentials"
  type        = bool
  default     = false
}


# Azure Authentication
variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = null
}

# Networking
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Address prefixes for the subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet_names" {
  description = "Names of the subnets"
  type        = list(string)
  default     = ["aks", "db", "appgw", "bastion"]
}

# AKS Network Configuration
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

# AKS
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

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "ssh_pub_keys/azureuser.pub"
}

# Security
variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "cert_manager_namespace" {
  description = "Namespace for Cert Manager"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_identity_name" {
  description = "Name of the Cert Manager managed identity"
  type        = string
  default     = "cert-manager-identity"
}

# DNS
variable "dns_zone_name" {
  description = "Name of the DNS zone"
  type        = string
  default     = "example.com"
}

variable "external_dns_namespace" {
  description = "Namespace for External DNS"
  type        = string
  default     = "external-dns"
}

variable "external_dns_identity_name" {
  description = "Name of the External DNS managed identity"
  type        = string
  default     = "external-dns-identity"
}

# Monitoring
variable "log_analytics_retention_days" {
  description = "Retention in days for Log Analytics data"
  type        = number
  default     = 30
}

# PostgreSQL Flexible Server
variable "postgresql_sku" {
  description = "SKU for PostgreSQL Flexible Server (e.g., B_Standard_B1ms, GP_Standard_D2s_v3)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage" {
  description = "Storage in MB for PostgreSQL"
  type        = number
  default     = 32768 # 32GB
}

variable "postgresql_version" {
  description = "PostgreSQL version (e.g., 12, 13, 14)"
  type        = string
  default     = "13"
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

# ACR
variable "acr_id" {
  description = "ID of the Azure Container Registry"
  type        = string
  default     = ""
}

# Application Gateway
variable "app_gateway_public_ip_id" {
  description = "ID of the Application Gateway public IP"
  type        = string
  default     = ""
}

# Module integration
variable "create_k8s_resources" {
  description = "Whether to create Kubernetes resources"
  type        = bool
  default     = true
}

variable "create_wildcard_record" {
  description = "Whether to create a wildcard DNS record"
  type        = bool
  default     = false
}

variable "create_federated_identity" {
  description = "Whether to create federated identity credential"
  type        = bool
  default     = true
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL for the AKS cluster"
  type        = string
  default     = ""
}

variable "admin_group_object_ids" {
  description = "Object IDs of Azure AD groups with admin access to the cluster"
  type        = list(string)
  default     = []
}

variable "create_dns_role_assignment" {
  description = "Whether to create the DNS Zone Contributor role assignment"
  type        = bool
  default     = false
}