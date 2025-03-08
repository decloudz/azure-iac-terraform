# Security Module

This module manages security resources for the GCSE Prime EDM project, including Azure Key Vault and managed identities.

## Resources Created

- Azure Key Vault
- Key Vault Access Policies
- Cert Manager Namespace
- Cert Manager Managed Identity
- Role Assignments
- Federated Identity Credentials

## Usage

```hcl
module "security" {
  source = "./modules/security"

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  environment                = var.environment
  project                    = var.project
  common_tags                = local.common_tags
  tenant_id                  = var.tenant_id
  aks_principal_id           = module.kubernetes.aks_principal_id
  key_vault_sku              = "standard"
  allowed_ip_ranges          = ["123.123.123.123/32"]
  allowed_subnet_ids         = [module.networking.aks_subnet_id]
  cert_manager_namespace     = "cert-manager"
  cert_manager_identity_name = "cert-manager-identity"
  dns_zone_id                = module.dns.dns_zone_id
  create_k8s_resources       = true
  create_federated_identity  = true
  oidc_issuer_url            = module.kubernetes.oidc_issuer_url
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
| tenant_id | Azure AD tenant ID | `string` | n/a | yes |
| aks_principal_id | Principal ID of the AKS cluster identity | `string` | n/a | yes |
| key_vault_sku | SKU for Key Vault | `string` | `"standard"` | no |
| allowed_ip_ranges | List of IP ranges allowed to access Key Vault | `list(string)` | `[]` | no |
| allowed_subnet_ids | List of subnet IDs allowed to access Key Vault | `list(string)` | `[]` | no |
| cert_manager_namespace | Namespace for Cert Manager | `string` | `"cert-manager"` | no |
| cert_manager_identity_name | Name of the Cert Manager managed identity | `string` | `"cert-manager-identity"` | no |
| dns_zone_id | ID of the DNS zone | `string` | `""` | no |
| create_k8s_resources | Whether to create Kubernetes resources | `bool` | `true` | no |
| create_federated_identity | Whether to create federated identity credential | `bool` | `true` | no |
| oidc_issuer_url | OIDC issuer URL | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | ID of the Key Vault |
| key_vault_name | Name of the Key Vault |
| key_vault_uri | URI of the Key Vault |
| cert_manager_identity_id | ID of the Cert Manager managed identity |
| cert_manager_identity_principal_id | Principal ID of the Cert Manager managed identity |
| cert_manager_identity_client_id | Client ID of the Cert Manager managed identity |

## Security Features

- Network access controls for Key Vault
- Purge protection for production environments
- Soft delete retention
- Managed identities for services
- Least privilege access policies 