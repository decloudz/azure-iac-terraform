# Kubernetes Module

This module manages the Azure Kubernetes Service (AKS) cluster and related resources for the GCSE Prime EDM project.

## Resources Created

- Azure Kubernetes Service (AKS) Cluster
- AKS Node Pool
- Role-Based Access Control (RBAC) configuration
- Azure Monitor integration
- ACR integration for pulling images

## Usage

```hcl
module "kubernetes" {
  source = "./modules/kubernetes"

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  environment                = var.environment
  project                    = var.project
  kubernetes_version         = "1.25.6"
  aks_vm_size                = "Standard_D2s_v3"
  aks_node_count             = 2
  aks_max_pods               = 30
  aks_admin_username         = "azureuser"
  common_tags                = local.common_tags
  vnet_id                    = module.networking.vnet_id
  subnet_id                  = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  ssh_public_key             = file("~/.ssh/id_rsa.pub")
  acr_id                     = module.acr.acr_id
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |
| environment | Environment name, such as 'dev', 'test', 'prod' | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| kubernetes_version | Kubernetes version | `string` | `"1.25.6"` | no |
| aks_vm_size | VM size for AKS nodes | `string` | `"Standard_D2s_v3"` | no |
| aks_node_count | Number of AKS nodes | `number` | `2` | no |
| aks_max_pods | Maximum number of pods per node | `number` | `30` | no |
| aks_admin_username | Admin username for AKS nodes | `string` | `"azureuser"` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| vnet_id | ID of the virtual network | `string` | n/a | yes |
| subnet_id | ID of the subnet for AKS | `string` | n/a | yes |
| log_analytics_workspace_id | ID of the Log Analytics Workspace for AKS monitoring | `string` | n/a | yes |
| ssh_public_key | SSH public key for AKS nodes | `string` | n/a | yes |
| acr_id | ID of the Azure Container Registry | `string` | `""` | no |
| admin_group_object_ids | Object IDs of Azure AD groups with admin access to the cluster | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| aks_id | ID of the AKS cluster |
| aks_name | Name of the AKS cluster |
| aks_fqdn | FQDN of the AKS cluster |
| kube_config | Kubernetes configuration |
| aks_principal_id | Principal ID of the AKS cluster identity |
| node_resource_group | Resource group for AKS node resources | 