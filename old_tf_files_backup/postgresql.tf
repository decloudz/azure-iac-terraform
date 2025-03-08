# Create an Azure resource group for PostgreSQL
resource "azurerm_resource_group" "rg_psql" {
  name     = "${var.rg_prefix}-${var.psql_rg_name}-${local.environment}"
  location = var.psql_location
  tags = merge(local.default_tags,
    {
      "CreatedBy" = "aadegboye"
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create private DNS zone for PostgreSQL 
resource "azurerm_private_dns_zone" "psql_dns_zone" {
  name                = "${var.psql_prefix}-${var.psql_name}-${local.environment}.private.postgres.database.azure.com"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  tags                = merge(local.default_tags, var.psql_tags)
  lifecycle {
    ignore_changes = [
      # tags
    ]
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Associate PostgreSQL Private DNS zone with virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "psql_dns_zone_vnet_associate" {
  name                  = "link_to_${azurerm_virtual_network.vnet.name}"
  resource_group_name   = azurerm_virtual_network.vnet.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.psql_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  tags = merge(local.default_tags, var.psql_tags)
  lifecycle {
    ignore_changes = [
      # tags
    ]
  }

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_private_dns_zone.psql_dns_zone
  ]
}


# Generate PostgreSQL admin random password
resource "random_password" "psql_admin_password" {
  length           = 20
  special          = true
  lower            = true
  upper            = true
  override_special = "!#$"
}

# Store PostgreSQL admin password in Azuure Key Vault
resource "azurerm_key_vault_secret" "psql_admin_password" {
  name         = "postgres-db-password"
  value        = random_password.psql_admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}
  depends_on = [
    azurerm_key_vault.kv,
    random_password.psql_admin_password,
  ]
}


# Create the Azure PostgreSQL - Flexible Server using terraform
resource "azurerm_postgresql_flexible_server" "psql" {
  name                   = lower("${var.psql_prefix}-${var.psql_name}-${local.environment}")
  resource_group_name    = azurerm_resource_group.rg_psql.name
  location               = azurerm_resource_group.rg_psql.location
  version                = var.psql_version
  delegated_subnet_id    = azurerm_subnet.psql.id
  private_dns_zone_id    = azurerm_private_dns_zone.psql_dns_zone.id
  administrator_login    = var.psql_admin_login
  administrator_password = azurerm_key_vault_secret.psql_admin_password.value
  # zone                    = "1"
  storage_mb = var.psql_storage_mb

  # Set the backup retention policy to 7 for non-prod, and 30 for prod
  backup_retention_days = 7

  sku_name = var.psql_sku_name
  depends_on = [
    azurerm_resource_group.rg_psql,
    azurerm_subnet.psql,
    azurerm_private_dns_zone.psql_dns_zone,
    azurerm_key_vault_secret.psql_admin_password
  ]
  tags = merge(local.default_tags, var.psql_tags)
  lifecycle {
    ignore_changes = [
      # tags,
      # private_dns_zone_id
    ]
  }
}