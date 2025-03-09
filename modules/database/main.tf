# Create PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "psql-flex-${var.project}-${var.environment}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password
  storage_mb             = var.postgresql_storage
  sku_name               = var.postgresql_sku
  tags                   = var.common_tags
  
  # High availability configuration - enable for production
  high_availability {
    mode = var.environment == "prod" ? "ZoneRedundant" : "Disabled"
  }
  
  # For production environments, enable geo-redundant backups
  backup_retention_days = var.environment == "prod" ? 35 : 7
  geo_redundant_backup_enabled = var.environment == "prod" ? true : false
  
  # Network configuration for private access
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  
  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

# Create a database in the PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.postgresql_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Create a private DNS zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

# Link the private DNS zone to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  tags                  = var.common_tags
}

# Configure firewall rule to allow Azure services access (optional)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  server_id           = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
} 