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


provider "random" {}

# Configuration for the Terraform AzureRM Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  use_msi                    = var.test_mode
  alias                      = "test"
}

# Kubernetes provider configuration with improved dependency handling
provider "kubernetes" {
  alias = "aks"
  
  # When in test mode or when not creating the cluster, we'll use an empty provider configuration
  # which won't try to connect to any cluster
  host                   = null
  client_certificate     = null
  client_key             = null
  cluster_ca_certificate = null

  # The exec block is only active when we create Kubernetes resources, and
  # the AKS cluster is expected to exist
  dynamic "exec" {
    for_each = var.test_mode || !var.create_k8s_resources ? [] : [1]
    
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "az"
      args = [
        "aks", "get-credentials",
        "--resource-group", local.resource_group_name,
        "--name", "aks-${var.project}-${var.environment}",
        "--overwrite-existing"
      ]
    }
  }
}

# Helm provider configuration with improved dependency handling
provider "helm" {
  alias = "aks"
  
  kubernetes {
    # When in test mode or when not creating the cluster, we'll use an empty provider configuration
    # which won't try to connect to any cluster
    host                   = null
    client_certificate     = null
    client_key             = null
    cluster_ca_certificate = null

    # The exec block is only active when we create Kubernetes resources, and
    # the AKS cluster is expected to exist
    dynamic "exec" {
      for_each = var.test_mode || !var.create_k8s_resources ? [] : [1]
      
      content {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "az"
        args = [
          "aks", "get-credentials",
          "--resource-group", local.resource_group_name,
          "--name", "aks-${var.project}-${var.environment}",
          "--overwrite-existing"
        ]
      }
    }
  }
}