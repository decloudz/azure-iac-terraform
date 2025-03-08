# Main Terraform configuration file
# This file orchestrates all modules for the GCSE Prime EDM infrastructure

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
}

# Database module
module "database" {
  source = "./modules/database"

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
}

# Security module
module "security" {
  source = "./modules/security"

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  environment                = var.environment
  project                    = var.project
  common_tags                = local.common_tags
  tenant_id                  = var.tenant_id
  aks_principal_id           = module.kubernetes.aks_principal_id
  key_vault_sku              = var.key_vault_sku
  cert_manager_namespace     = var.cert_manager_namespace
  cert_manager_identity_name = var.cert_manager_identity_name
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

  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.location
  environment               = var.environment
  project                   = var.project
  common_tags               = local.common_tags
  dns_zone_name             = var.dns_zone_name
  external_dns_namespace    = var.external_dns_namespace
  external_dns_identity_name = var.external_dns_identity_name
  aks_principal_id          = module.kubernetes.aks_principal_id
} 