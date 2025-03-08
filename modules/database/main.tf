# Database module - main.tf
# This module manages PostgreSQL database and related resources

# PostgreSQL Server
resource "azurerm_postgresql_server" "postgres" {
  name                = "psql-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  sku_name   = var.postgresql_sku
  version    = var.postgresql_version
  storage_mb = var.postgresql_storage

  administrator_login          = var.postgresql_admin_username
  administrator_login_password = var.postgresql_admin_password
  ssl_enforcement_enabled      = true
  public_network_access_enabled = false

  geo_redundant_backup_enabled = var.environment == "prod" ? true : false
  backup_retention_days        = var.environment == "prod" ? 35 : 7
}

# PostgreSQL Database
resource "azurerm_postgresql_database" "db" {
  name                = var.postgresql_db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Private endpoint for PostgreSQL
resource "azurerm_private_endpoint" "postgres_endpoint" {
  name                = "pe-postgres-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.common_tags

  private_service_connection {
    name                           = "psc-postgres-${var.environment}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_postgresql_server.postgres.id
    subresource_names              = ["postgresqlServer"]
  }
} 