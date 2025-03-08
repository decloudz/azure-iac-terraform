terraform {
  backend "azurerm" {
    # These values are intentionally left empty as they will be set by the Azure DevOps pipeline
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstategcse"
    container_name       = "tfstate"
    key                  = "gcse-prime-edm.tfstate"
  }
} 