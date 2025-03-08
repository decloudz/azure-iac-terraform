# Database Module

This module manages the PostgreSQL database and related resources for the GCSE Prime EDM project.

## Resources Created

- Azure Database for PostgreSQL Server
- PostgreSQL Database
- Private Endpoint for secure connectivity
- Backup retention policies based on environment

## Usage

```hcl
module "database" {
  source = "./modules/database"

  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.location
  environment               = var.environment
  project                   = var.project
  common_tags               = local.common_tags
  vnet_id                   = module.networking.vnet_id
  subnet_id                 = module.networking.db_subnet_id
  postgresql_sku            = "GP_Gen5_2"
  postgresql_storage        = 102400
  postgresql_version        = "11"
  postgresql_admin_username = "psqladmin"
  postgresql_admin_password = var.postgresql_admin_password
  postgresql_db_name        = "appdb"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |
| environment | Environment name, such as 'dev', 'test', 'prod' | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| vnet_id | ID of the virtual network | `string` | n/a | yes |
| subnet_id | ID of the subnet for database | `string` | n/a | yes |
| postgresql_sku | SKU for PostgreSQL | `string` | `"GP_Gen5_2"` | no |
| postgresql_storage | Storage in MB for PostgreSQL | `number` | `102400` | no |
| postgresql_version | PostgreSQL version | `string` | `"11"` | no |
| postgresql_admin_username | PostgreSQL admin username | `string` | `"psqladmin"` | no |
| postgresql_admin_password | PostgreSQL admin password | `string` | n/a | yes |
| postgresql_db_name | PostgreSQL database name | `string` | `"appdb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| postgresql_server_id | ID of the PostgreSQL server |
| postgresql_server_name | Name of the PostgreSQL server |
| postgresql_server_fqdn | FQDN of the PostgreSQL server |
| postgresql_database_name | Name of the PostgreSQL database |
| postgresql_connection_string | PostgreSQL connection string |

## Security Features

- Private endpoint for secure connectivity
- SSL enforcement enabled
- Public network access disabled
- Geo-redundant backups for production environment
- Extended backup retention for production environment 