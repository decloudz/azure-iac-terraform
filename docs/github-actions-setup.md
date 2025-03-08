# Setting Up GitHub Actions for Terraform Deployment

This guide explains how to set up GitHub Actions for automated Terraform deployments to Azure, replacing Azure DevOps pipelines.

## 1. GitHub Repository Setup

Ensure your repository contains the following structure:
- `clean-azure-iac-terraform/` - Main Terraform configuration
- `.github/workflows/terraform.yml` - GitHub Actions workflow file

## 2. Configure GitHub Secrets

You need to add the following secrets to your GitHub repository:

1. Go to your repository → Settings → Secrets and variables → Actions → New repository secret

2. Add these required secrets:

   | Secret Name | Description |
   |-------------|-------------|
   | `AZURE_CLIENT_ID` | Azure Service Principal Client ID |
   | `AZURE_TENANT_ID` | Azure Tenant ID |
   | `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
   | `POSTGRESQL_ADMIN_PASSWORD` | Password for PostgreSQL admin user |
   
   For secure authentication, we recommend using the OpenID Connect (OIDC) method with Azure. This avoids storing the client secret in GitHub.

## 3. Configure GitHub Variables

GitHub Actions also supports variables that don't need to be kept secret:

1. Go to your repository → Settings → Secrets and variables → Actions → Variables tab → New repository variable

2. Add these required variables:

   | Variable Name | Example Value | Description |
   |---------------|---------------|-------------|
   | `PROJECT` | gcse-prime-edm | Project name |
   | `LOCATION` | eastus2 | Azure region |
   | `OWNER` | DevOps Team | Resource owner |
   | `COST_CENTER` | IT-12345 | Cost center for billing |
   | `VNET_ADDRESS_SPACE` | 10.0.0.0/16 | Virtual network address space |
   | `SUBNET_PREFIXES` | ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"] | Subnet prefixes (as JSON array) |
   | `SUBNET_NAMES` | ["aks", "db", "appgw", "bastion"] | Subnet names (as JSON array) |
   | `KUBERNETES_VERSION` | 1.25.6 | Kubernetes version |
   | `AKS_VM_SIZE` | Standard_D2s_v3 | AKS node VM size |
   | `AKS_NODE_COUNT` | 2 | Number of AKS nodes |
   | `AKS_MAX_PODS` | 30 | Max pods per node |
   | `KEY_VAULT_SKU` | standard | Key Vault SKU |
   | `CERT_MANAGER_NAMESPACE` | cert-manager | Cert Manager namespace |
   | `CERT_MANAGER_IDENTITY_NAME` | cert-manager-identity | Cert Manager identity name |
   | `DNS_ZONE_NAME` | example.com | DNS zone name |
   | `CREATE_K8S_RESOURCES` | true | Whether to create Kubernetes resources |
   | `CREATE_FEDERATED_IDENTITY` | true | Whether to create federated identity |
   | `CREATE_WILDCARD_RECORD` | false | Whether to create wildcard DNS record |

## 4. Setting up Azure for OIDC Authentication

To use OIDC authentication between GitHub Actions and Azure:

1. Create an App Registration in Azure AD:
   ```bash
   az ad app create --display-name "GitHub-Actions-OIDC"
   ```

2. Create a service principal:
   ```bash
   clientId=$(az ad app list --display-name "GitHub-Actions-OIDC" --query "[].appId" -o tsv)
   az ad sp create --id $clientId
   ```

3. Assign the necessary roles:
   ```bash
   subscriptionId=$(az account show --query id -o tsv)
   az role assignment create --assignee $clientId --role Contributor --scope /subscriptions/$subscriptionId
   ```

4. Add Federated Credentials for GitHub Actions:
   ```bash
   az ad app federated-credential create \
     --id $clientId \
     --parameters "{\"name\":\"github-actions\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:your-org/your-repo:environment:dev\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
   ```

   Replace `your-org/your-repo` with your GitHub organization and repository name.

5. Add these credentials to GitHub Secrets as described above.

## 5. Running the GitHub Actions Workflow

The workflow will run automatically on:
- Pull requests to the main branch (plan only)
- Pushes to the main branch
- Manual triggers

For manual deployment:
1. Go to the "Actions" tab in your repository
2. Select the "Terraform CI/CD" workflow
3. Click "Run workflow"
4. Select the environment and whether to run in test mode
5. Click "Run workflow" again

## 6. Environments for Approval Workflows

For production deployments, you can set up required approvals:

1. Go to your repository → Settings → Environments
2. Create or select the "prod" environment
3. Add "Required reviewers" and select the users/teams who can approve
4. After the workflow runs the plan step, it will wait for approval before applying 