# Monitoring Module

This module manages monitoring resources for the GCSE Prime EDM project.

## Resources Created

- Log Analytics Workspace
- Container Insights Solution
- Application Insights
- Action Group for Alerts

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.location
  environment            = var.environment
  project                = var.project
  common_tags            = local.common_tags
  log_analytics_sku      = "PerGB2018"
  retention_in_days      = 30
  alert_email_addresses  = ["alerts@example.com", "ops@example.com"]
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
| log_analytics_sku | SKU for Log Analytics Workspace | `string` | `"PerGB2018"` | no |
| retention_in_days | Data retention in days for Log Analytics Workspace | `number` | `30` | no |
| alert_email_addresses | Email addresses for alerts | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_analytics_workspace_id | ID of the Log Analytics Workspace |
| log_analytics_workspace_name | Name of the Log Analytics Workspace |
| log_analytics_workspace_primary_key | Primary shared key for the Log Analytics Workspace |
| app_insights_instrumentation_key | Instrumentation key for Application Insights |
| app_insights_app_id | App ID for Application Insights |
| action_group_id | ID of the Action Group for critical alerts |

## Monitoring Capabilities

- Container monitoring for AKS
- Application performance monitoring
- Log collection and analysis
- Alert notifications 