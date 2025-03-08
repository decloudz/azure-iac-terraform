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
  description = "ID of the subnet for database"
  type        = string
}

variable "postgresql_sku" {
  description = "SKU for PostgreSQL"
  type        = string
  default     = "GP_Gen5_2"
}

variable "postgresql_storage" {
  description = "Storage in MB for PostgreSQL"
  type        = number
  default     = 102400
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "11"
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