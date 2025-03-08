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

variable "dns_zone_name" {
  description = "Name of the DNS zone"
  type        = string
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

variable "create_wildcard_record" {
  description = "Whether to create a wildcard DNS record"
  type        = bool
  default     = true
}

variable "app_gateway_public_ip_id" {
  description = "ID of the Application Gateway public IP"
  type        = string
  default     = ""
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS cluster identity"
  type        = string
  default     = ""
} 