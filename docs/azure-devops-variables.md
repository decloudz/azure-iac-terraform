# Setting Up Azure DevOps Variable Groups for Terraform CI/CD

This guide provides detailed instructions for setting up variable groups in Azure DevOps to support our Terraform CI/CD pipeline.

## Why We Need Variable Groups

Our Terraform configurations require various input variables to deploy infrastructure. Since we've added our `.tfvars` files to `.gitignore` to prevent committing sensitive information, we need an alternative way to provide these variables to our CI/CD pipeline.

Azure DevOps variable groups provide a secure, centralized way to manage these variables and make them available to our pipeline.

## Variable Group Structure

Our pipeline uses the following variable groups:

1. **GCSE-PrimeEDM-Common** - Common variables used across all environments
2. **GCSE-PrimeEDM-Dev** - Variables specific to the dev environment
3. **GCSE-PrimeEDM-Staging** - Variables specific to the staging environment
4. **GCSE-PrimeEDM-Prod** - Variables specific to the production environment

## Required Variables

### Common Variables (GCSE-PrimeEDM-Common)

| Variable Name | Description | Example Value | Secret? |
|---------------|-------------|---------------|---------|
| project | Project name | gcse-prime-edm | No |
| owner | Owner of the project | DevOps Team | No |
| costCenter | Cost center for billing | IT-12345 | No |
| tenantId | Azure tenant ID | 00000000-0000-0000-0000-000000000000 | No |
| clientId | Azure client ID | 00000000-0000-0000-0000-000000000000 | No |
| subscriptionId | Azure subscription ID | 00000000-0000-0000-0000-000000000000 | No |
| vnetAddressSpace | VNET address space | 10.0.0.0/16 | No |
| subnetPrefixes | Subnet prefixes (JSON array) | ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"] | No |
| subnetNames | Subnet names (JSON array) | ["aks", "db", "appgw", "bastion"] | No |
| certManagerNamespace | Namespace for cert-manager | cert-manager | No |
| certManagerIdentityName | Identity name for cert-manager | cert-manager-identity | No |
| externalDnsNamespace | Namespace for external-dns | external-dns | No |
| externalDnsIdentityName | Identity name for external-dns | external-dns-identity | No |
| keyVaultSku | SKU for Key Vault | standard | No |
| createK8sResources | Whether to create Kubernetes resources | true | No |
| createFederatedIdentity | Whether to create federated identity | true | No |
| createWildcardRecord | Whether to create wildcard DNS record | false | No |
| aksAdminUsername | Admin username for AKS nodes | azureuser | No |
| logAnalyticsRetentionDays | Retention days for Log Analytics | 30 | No |

### Environment-Specific Variables (GCSE-PrimeEDM-Dev, GCSE-PrimeEDM-Staging, GCSE-PrimeEDM-Prod)

| Variable Name | Description | Example Value | Secret? |
|---------------|-------------|---------------|---------|
| location | Azure region | eastus2 | No |
| kubernetesVersion | Kubernetes version | 1.25.6 | No |
| aksNodeCount | Number of nodes in AKS cluster | 2 | No |
| aksVmSize | VM size for AKS nodes | Standard_D2s_v3 | No |
| aksMaxPods | Maximum pods per node | 30 | No |
| dnsZoneName | DNS zone name | example.com | No |
| postgresqlAdminPassword | Password for PostgreSQL admin | (strong password) | Yes |

## Setting Up Variable Groups Using Azure Portal

1. Go to your Azure DevOps project
2. Navigate to **Pipelines** > **Library**
3. Click **+ Variable Group**
4. Enter the name (e.g., GCSE-PrimeEDM-Common)
5. Add the variables one by one
6. Check the "Lock" button for sensitive variables
7. Click **Save**
8. Repeat for each variable group

## Setting Up Variable Groups Using Script

We've created a helper script `scripts/azure-devops-variable-groups.sh` that can generate the necessary Azure CLI commands to create these variable groups and populate them with your values.

### Prerequisites

1. Install the Azure CLI
2. Install the Azure DevOps extension:
   ```bash
   az extension add --name azure-devops
   ```
3. Login to Azure:
   ```bash
   az login
   ```
4. Configure the Azure DevOps CLI:
   ```bash
   az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT
   ```

### Using the Script

1. Ensure you have your `environments/dev-variables.tfvars` file with your actual variable values
2. Update the script configuration with your organization and project details:
   ```bash
   # Edit the script and update these values
   ORGANIZATION="https://dev.azure.com/your-organization"
   PROJECT="your-project"
   ```
3. Run the script to generate the commands:
   ```bash
   cd clean-azure-iac-terraform
   ./scripts/azure-devops-variable-groups.sh > variable-group-commands.sh
   ```
4. Review the generated commands in `variable-group-commands.sh`
5. Make any necessary adjustments (especially for sensitive variables)
6. Execute the commands:
   ```bash
   chmod +x variable-group-commands.sh
   ./variable-group-commands.sh
   ```

## Manual Steps for Sensitive Variables

For sensitive variables like passwords and secrets, it's recommended to add them directly through the Azure DevOps portal rather than through scripts:

1. Go to your Azure DevOps project
2. Navigate to **Pipelines** > **Library**
3. Find the relevant variable group (e.g., GCSE-PrimeEDM-Dev)
4. Click **Edit**
5. Add the sensitive variable (e.g., postgresqlAdminPassword)
6. Check the "Lock" button to mark it as secret
7. Click **Save**

## Verifying Your Setup

After setting up all variable groups, you can verify they're accessible to your pipeline:

1. Go to your pipeline definition
2. Add a simple test step to the YAML:
   ```yaml
   - bash: |
       echo "Project: $(project)"
       echo "Location: $(location)"
     displayName: 'Test Variables'
   ```
3. Run the pipeline and check the logs to ensure the variables are correctly loaded

## Troubleshooting

If variables aren't being correctly loaded in your pipeline:

1. Check that the variable group names match exactly (case-sensitive)
2. Verify the variable names match what's referenced in the pipeline
3. Ensure the variable groups are linked to the pipeline
4. Check that the pipeline has permission to access the variable groups

Remember that any changes to variables will only apply to future pipeline runs, not currently running ones. 