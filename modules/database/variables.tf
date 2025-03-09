variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name, such as 'dev', 'test', 'prod'"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for database - must be delegated to Microsoft.DBforPostgreSQL/flexibleServers"
  type        = string
}

variable "postgresql_sku" {
  description = "SKU for PostgreSQL Flexible Server (e.g., B_Standard_B1ms, GP_Standard_D2s_v3)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage" {
  description = "Storage in MB for PostgreSQL"
  type        = number
  default     = 32768 # 32GB
}

variable "postgresql_version" {
  description = "PostgreSQL version (e.g., 12, 13, 14)"
  type        = string
  default     = "13"
}

variable "postgresql_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "psqladmin"
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgresql_db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "appdb"
} 