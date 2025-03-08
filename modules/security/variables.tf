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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS cluster identity"
  type        = string
}

variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access Key Vault"
  type        = list(string)
  default     = []
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

variable "dns_zone_id" {
  description = "ID of the DNS zone"
  type        = string
  default     = ""
}

variable "create_k8s_resources" {
  description = "Whether to create Kubernetes resources"
  type        = bool
  default     = true
}

variable "create_federated_identity" {
  description = "Whether to create federated identity credential"
  type        = bool
  default     = true
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
  default     = ""
} 