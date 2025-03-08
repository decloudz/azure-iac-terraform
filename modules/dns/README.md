# DNS Module

This module manages DNS zones and records for the GCSE Prime EDM project.

## Resources Created

- Azure DNS Zone
- External DNS Namespace
- External DNS Managed Identity
- Role Assignments
- Federated Identity Credentials
- DNS Records (optional)

## Usage

```hcl
module "dns" {
  source = "./modules/dns"

  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.location
  environment               = var.environment
  project                   = var.project
  common_tags               = local.common_tags
  dns_zone_name             = "example.com"
  external_dns_namespace    = "external-dns"
  external_dns_identity_name = "external-dns-identity"
  create_k8s_resources      = true
  create_federated_identity = true
  oidc_issuer_url           = module.kubernetes.oidc_issuer_url
  create_wildcard_record    = true
  app_gateway_public_ip_id  = module.networking.app_gateway_public_ip_id
  aks_principal_id          = module.kubernetes.aks_principal_id
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
| dns_zone_name | Name of the DNS zone | `string` | n/a | yes |
| external_dns_namespace | Namespace for External DNS | `string` | `"external-dns"` | no |
| external_dns_identity_name | Name of the External DNS managed identity | `string` | `"external-dns-identity"` | no |
| create_k8s_resources | Whether to create Kubernetes resources | `bool` | `true` | no |
| create_federated_identity | Whether to create federated identity credential | `bool` | `true` | no |
| oidc_issuer_url | OIDC issuer URL | `string` | `""` | no |
| create_wildcard_record | Whether to create a wildcard DNS record | `bool` | `true` | no |
| app_gateway_public_ip_id | ID of the Application Gateway public IP | `string` | `""` | no |
| aks_principal_id | Principal ID of the AKS cluster identity | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| dns_zone_id | ID of the DNS zone |
| dns_zone_name | Name of the DNS zone |
| name_servers | Name servers for the DNS zone |
| external_dns_identity_id | ID of the External DNS managed identity |
| external_dns_identity_principal_id | Principal ID of the External DNS managed identity |
| external_dns_identity_client_id | Client ID of the External DNS managed identity |

## DNS Automation

This module works with the External DNS Kubernetes operator to automatically manage DNS records. The External DNS identity uses workload identity federation to securely authenticate with Azure without storing credentials. 