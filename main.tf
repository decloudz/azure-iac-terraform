# Main Terraform configuration file
# This file orchestrates all modules for the GCSE Prime EDM infrastructure

# Add at the top of the file
locals {
  # Skip actual creation of Azure resources when in test mode
  should_create_resources = !var.test_mode
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Networking module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  vnet_address_space  = var.vnet_address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  common_tags         = local.common_tags
}

# Kubernetes module
module "kubernetes" {
  source = "./modules/kubernetes"
  count  = local.should_create_resources ? 1 : 0

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  environment                = var.environment
  project                    = var.project
  kubernetes_version         = var.kubernetes_version
  aks_vm_size                = var.aks_vm_size
  aks_node_count             = var.aks_node_count
  aks_max_pods               = var.aks_max_pods
  aks_admin_username         = var.aks_admin_username
  common_tags                = local.common_tags
  vnet_id                    = module.networking.vnet_id
  subnet_id                  = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  ssh_public_key             = file(var.ssh_public_key_path)
  acr_id                     = var.acr_id
  admin_group_object_ids     = var.admin_group_object_ids
}

# Database module
module "database" {
  source = "./modules/database"
  count  = local.should_create_resources ? 1 : 0

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  common_tags         = local.common_tags
  vnet_id             = module.networking.vnet_id
  subnet_id           = module.networking.db_subnet_id
  postgresql_sku      = var.postgresql_sku
  postgresql_storage  = var.postgresql_storage
  postgresql_version  = var.postgresql_version
  postgresql_admin_password = var.postgresql_admin_password
}

# Security module
module "security" {
  source = "./modules/security"
  count  = local.should_create_resources ? 1 : 0

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  environment                = var.environment
  project                    = var.project
  common_tags                = local.common_tags
  tenant_id                  = var.tenant_id
  aks_principal_id           = local.should_create_resources ? module.kubernetes[0].aks_principal_id : ""
  key_vault_sku              = var.key_vault_sku
  cert_manager_namespace     = var.cert_manager_namespace
  cert_manager_identity_name = var.cert_manager_identity_name
  dns_zone_id                = local.should_create_resources ? module.dns[0].dns_zone_id : ""
  create_k8s_resources       = var.create_k8s_resources
  create_federated_identity  = var.create_federated_identity
  create_dns_role_assignment = var.create_dns_role_assignment
  oidc_issuer_url            = var.oidc_issuer_url
}

# Monitoring module
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  common_tags         = local.common_tags
  retention_in_days   = var.log_analytics_retention_days
}

# DNS module
module "dns" {
  source = "./modules/dns"
  count  = local.should_create_resources ? 1 : 0

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  environment                = var.environment
  project                    = var.project
  common_tags                = local.common_tags
  dns_zone_name              = var.dns_zone_name
  external_dns_namespace     = var.external_dns_namespace
  external_dns_identity_name = var.external_dns_identity_name
  create_k8s_resources       = var.create_k8s_resources
  create_federated_identity  = var.create_federated_identity
  oidc_issuer_url            = var.oidc_issuer_url
  create_wildcard_record     = var.create_wildcard_record
  app_gateway_public_ip_id   = var.app_gateway_public_ip_id
  aks_principal_id           = local.should_create_resources ? module.kubernetes[0].aks_principal_id : ""
} 