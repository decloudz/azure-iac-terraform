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
  default     = "eastus2"
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

# PostgreSQL
variable "postgresql_sku" {
  description = "SKU for PostgreSQL"
  type        = string
  default     = "GP_Gen5_2"
}

variable "postgresql_storage" {
  description = "Storage in MB for PostgreSQL"
  type        = number
  default     = 102400  # 100 GB
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "11"
}

variable "postgresql_admin_password" {
  description = "Password for the PostgreSQL database administrator"
  type        = string
  sensitive   = true
} 