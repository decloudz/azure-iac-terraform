# Networking Module

This module manages the network infrastructure for the GCSE Prime EDM project.

## Resources Created

- Virtual Network
- Subnets (AKS, DB, AppGateway, Bastion)
- Network Security Groups
- NSG Rules
- Subnet-NSG Associations

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  project             = var.project
  vnet_address_space  = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  subnet_names        = ["aks", "db", "appgw", "bastion"]
  common_tags         = local.common_tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |
| environment | Environment name, such as 'dev', 'test', 'prod' | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| vnet_address_space | Address space for the virtual network | `list(string)` | `["10.0.0.0/16"]` | no |
| subnet_prefixes | Address prefixes for the subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]` | no |
| subnet_names | Names of the subnets | `list(string)` | `["aks", "db", "appgw", "bastion"]` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | ID of the virtual network |
| vnet_name | Name of the virtual network |
| aks_subnet_id | ID of the AKS subnet |
| db_subnet_id | ID of the database subnet |
| appgw_subnet_id | ID of the Application Gateway subnet |
| bastion_subnet_id | ID of the Bastion subnet |
| subnet_ids | IDs of all subnets | 