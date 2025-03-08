output "postgresql_server_id" {
  description = "ID of the PostgreSQL server"
  value       = azurerm_postgresql_server.postgres.id
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_server.postgres.name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_server.postgres.fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = azurerm_postgresql_database.db.name
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgres://${azurerm_postgresql_server.postgres.administrator_login}@${azurerm_postgresql_server.postgres.name}:${azurerm_postgresql_server.postgres.administrator_login_password}@${azurerm_postgresql_server.postgres.fqdn}:5432/${azurerm_postgresql_database.db.name}"
  sensitive   = true
} 