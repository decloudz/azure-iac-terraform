locals {
  # Skip actual creation of Azure resources when in test mode
  should_create_resources = !var.test_mode

  # Resource name components
  resource_prefix     = "${var.project}-${var.environment}"
  resource_group_name = "rg-${local.resource_prefix}"

  # Get OIDC issuer URL if AKS exists
  oidc_issuer_url = local.should_create_resources && length(module.kubernetes) > 0 ? module.kubernetes[0].oidc_issuer_url : ""
  
  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
  
  # Naming conventions
  aks_name             = "aks-${local.resource_prefix}"
  acr_name             = "acr${replace(local.resource_prefix, "-", "")}"  # ACR can't have hyphens
  vnet_name            = "vnet-${local.resource_prefix}"
  keyvault_name        = "kv-${local.resource_prefix}"
  log_analytics_name   = "law-${local.resource_prefix}"
  application_insights = "appi-${local.resource_prefix}"
  postgresql_name      = "psql-${local.resource_prefix}"
  
  # Networking
  bastion_subnet_name = "AzureBastionSubnet"  # Required name for Azure Bastion
}
