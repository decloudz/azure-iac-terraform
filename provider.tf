terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
  required_version = ">= 1.3.9"
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

provider "random" {}

# Configuration for the Terraform AzureRM Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }
  
  # Support both OIDC authentication from GitHub Actions and standard Service Principal auth
  # When using GitHub Actions OIDC, use_oidc will be set to true in the workflow and Azure login 
  # will provide the tokens needed. Otherwise, fall back to Service Principal credentials.
  
  # For GitHub Actions OIDC, the environment variables will be automatically set:
  # - ARM_CLIENT_ID
  # - ARM_TENANT_ID 
  # - ARM_SUBSCRIPTION_ID
  # - ARM_USE_OIDC=true
  
  # For local development or external CI/CD systems:
  subscription_id            = var.test_mode ? null : var.subscription_id
  client_id                  = var.test_mode ? null : var.client_id
  client_secret              = var.test_mode ? null : var.client_secret
  tenant_id                  = var.test_mode ? null : var.tenant_id
  
  skip_provider_registration = true
}

# For test mode, specify mock validation
provider "azurerm" {
  features {}
  skip_provider_registration = true
  use_msi                    = var.test_mode
  alias                      = "test"
}