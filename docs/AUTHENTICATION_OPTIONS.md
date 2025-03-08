# Azure DevOps Authentication Options for Terraform Pipelines

This document outlines various methods for authenticating Azure DevOps pipelines to Azure when running Terraform operations. Each method has its own advantages, security considerations, and implementation complexity.

## 1. Azure DevOps Service Connections

**Description:** The traditional approach using Service Connections in Azure DevOps to authenticate to Azure.

**Implementation:**
```yaml
- task: TerraformTaskV3@3
  displayName: 'Terraform Init'
  inputs:
    provider: 'azurerm'
    command: 'init'
    workingDirectory: '$(workingDirectory)'
    backendServiceArm: 'MyAzureServiceConnection'
    backendAzureRmResourceGroupName: '$(tfStateResourceGroup)'
    backendAzureRmStorageAccountName: '$(tfStateStorageAccount)'
    backendAzureRmContainerName: '$(tfStateContainer)'
    backendAzureRmKey: '$(tfStateKey)'
```

**Pros:**
- Easy setup through Azure DevOps UI
- Built-in integration with Terraform tasks
- Abstracts credential management

**Cons:**
- Service principal credentials stored in Azure DevOps
- Limited auditability
- Manual setup required for each connection

**Setup Requirements:**
1. Create a service principal in Azure AD
2. Configure service connection in Azure DevOps
3. Assign necessary permissions to the service principal

## 2. Environment Variables with Azure CLI

**Description:** Use environment variables with direct Azure CLI authentication in pipeline tasks.

**Implementation:**
```yaml
- task: AzureCLI@2
  displayName: 'Azure Login and Set Environment'
  inputs:
    azureSubscription: 'MyAzureServiceConnection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Export Terraform environment variables for Azure authentication
      echo "##vso[task.setvariable variable=ARM_CLIENT_ID]$(az account show --query id -o tsv)"
      echo "##vso[task.setvariable variable=ARM_SUBSCRIPTION_ID]$(az account show --query id -o tsv)"
      echo "##vso[task.setvariable variable=ARM_TENANT_ID]$(az account show --query tenantId -o tsv)"

- task: Bash@3
  displayName: 'Terraform Commands'
  inputs:
    targetType: 'inline'
    script: |
      cd $(workingDirectory)
      terraform init \
        -backend-config="resource_group_name=$(tfStateResourceGroup)" \
        -backend-config="storage_account_name=$(tfStateStorageAccount)" \
        -backend-config="container_name=$(tfStateContainer)" \
        -backend-config="key=$(tfStateKey)"
      
      terraform plan -var-file="environments/$(environmentName)-variables.tfvars" -out=tfplan
      terraform apply -auto-approve tfplan
  env:
    ARM_CLIENT_ID: $(ARM_CLIENT_ID)
    ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
    ARM_TENANT_ID: $(ARM_TENANT_ID)
```

**Pros:**
- Reduces need for separate service connections
- Works with standard Bash tasks
- More transparent authentication flow

**Cons:**
- Still requires initial service connection for Azure CLI task
- May expose credentials in pipeline logs if not properly configured

**Setup Requirements:**
1. Create a service connection for the initial Azure CLI task
2. Configure pipeline YAML with appropriate environment variables

## 3. Workload Identity Federation (OIDC) - Modern Approach

**Description:** Use OpenID Connect (OIDC) to establish a trust relationship between Azure AD and Azure DevOps, eliminating the need for storing secrets.

**Implementation:**
```yaml
- task: AzureCLI@2
  displayName: 'Configure Azure OIDC Authentication'
  inputs:
    azureSubscription: 'AzureServiceConnection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Export Azure authentication environment variables
      echo "##vso[task.setvariable variable=ARM_USE_OIDC]true"
      echo "##vso[task.setvariable variable=ARM_CLIENT_ID]$(clientId)"
      echo "##vso[task.setvariable variable=ARM_TENANT_ID]$(tenantId)"
      echo "##vso[task.setvariable variable=ARM_SUBSCRIPTION_ID]$(subscriptionId)"
      echo "##vso[task.setvariable variable=ARM_OIDC_TOKEN]$(az account get-access-token --query accessToken -o tsv)"

- task: Bash@3
  displayName: 'Terraform Commands'
  inputs:
    targetType: 'inline'
    script: |
      cd $(workingDirectory)
      terraform init \
        -backend-config="resource_group_name=$(tfStateResourceGroup)" \
        -backend-config="storage_account_name=$(tfStateStorageAccount)" \
        -backend-config="container_name=$(tfStateContainer)" \
        -backend-config="key=$(tfStateKey)"
  env:
    ARM_USE_OIDC: $(ARM_USE_OIDC)
    ARM_CLIENT_ID: $(ARM_CLIENT_ID)
    ARM_TENANT_ID: $(ARM_TENANT_ID)
    ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
    ARM_OIDC_TOKEN: $(ARM_OIDC_TOKEN)
```

**Pros:**
- Enhanced security - no secrets stored anywhere
- Automatic credential rotation
- Simplified management
- Follows Zero Trust security model

**Cons:**
- Requires Azure AD configuration
- Only supported in newer Terraform versions
- More complex initial setup

**Setup Requirements:**
1. Register an app in Azure AD
2. Configure federated credentials for Azure DevOps (organization/project/pipeline)
3. Assign appropriate RBAC permissions to the application
4. Configure OIDC service connection in Azure DevOps

## 4. Azure Managed Identity (Self-Hosted Agents)

**Description:** For self-hosted agents running on Azure VMs, leverage Managed Identity for authentication.

**Implementation:**
```yaml
- task: Bash@3
  displayName: 'Terraform Commands with Managed Identity'
  inputs:
    targetType: 'inline'
    script: |
      # Get token from instance metadata service
      token=$(curl -s -H "Metadata:true" -H "X-IDENTITY-HEADER:$(az vm identity show -g myResourceGroup -n myVM --query systemAssignedIdentity -o tsv)" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" | jq -r .access_token)
      
      # Export for Terraform
      export ARM_USE_MSI=true
      export ARM_MSI_ENDPOINT="http://169.254.169.254/metadata/identity/oauth2/token"
      export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
      export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
      
      cd $(workingDirectory)
      terraform init \
        -backend-config="resource_group_name=$(tfStateResourceGroup)" \
        -backend-config="storage_account_name=$(tfStateStorageAccount)" \
        -backend-config="container_name=$(tfStateContainer)" \
        -backend-config="key=$(tfStateKey)"
```

**Pros:**
- No credentials to manage
- Highly secure
- Simplified pipeline configuration
- Reduced exposure of sensitive information

**Cons:**
- Only works with self-hosted agents on Azure VMs
- VM must be properly configured with managed identity
- Requires proper RBAC setup for the managed identity

**Setup Requirements:**
1. Configure a self-hosted agent on an Azure VM
2. Assign a managed identity to the VM
3. Grant appropriate RBAC permissions to the managed identity

## 5. Azure Key Vault Integration

**Description:** Store credentials securely in Azure Key Vault and retrieve them during pipeline execution.

**Implementation:**
```yaml
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'AzureServiceConnection'
    KeyVaultName: 'mykeyvault'
    SecretsFilter: 'ARM-CLIENT-ID,ARM-CLIENT-SECRET,ARM-TENANT-ID,ARM-SUBSCRIPTION-ID'
    RunAsPreJob: true

- task: Bash@3
  displayName: 'Terraform Commands with Key Vault Secrets'
  inputs:
    targetType: 'inline'
    script: |
      cd $(workingDirectory)
      terraform init \
        -backend-config="resource_group_name=$(tfStateResourceGroup)" \
        -backend-config="storage_account_name=$(tfStateStorageAccount)" \
        -backend-config="container_name=$(tfStateContainer)" \
        -backend-config="key=$(tfStateKey)"
  env:
    ARM_CLIENT_ID: $(ARM-CLIENT-ID)
    ARM_CLIENT_SECRET: $(ARM-CLIENT-SECRET)
    ARM_TENANT_ID: $(ARM-TENANT-ID)
    ARM_SUBSCRIPTION_ID: $(ARM-SUBSCRIPTION-ID)
```

**Pros:**
- Centralizes credential storage
- Improves security posture
- Simplified credential rotation
- Enhanced audit capabilities

**Cons:**
- Requires setup and management of Key Vault
- Still requires initial service connection to access Key Vault
- Adds complexity to pipeline configuration

**Setup Requirements:**
1. Create an Azure Key Vault
2. Store service principal credentials as secrets
3. Configure access policies for the pipeline's identity
4. Set up the Key Vault task in the pipeline

## 6. Azure CLI Login with Protected Variables

**Description:** Use Azure CLI to login with service principal credentials stored as protected pipeline variables.

**Implementation:**
```yaml
- task: Bash@3
  displayName: 'Azure Login'
  inputs:
    targetType: 'inline'
    script: |
      az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant $(ARM_TENANT_ID)
      az account set -s $(ARM_SUBSCRIPTION_ID)

- task: Bash@3
  displayName: 'Terraform Commands'
  inputs:
    targetType: 'inline'
    script: |
      cd $(workingDirectory)
      terraform init \
        -backend-config="resource_group_name=$(tfStateResourceGroup)" \
        -backend-config="storage_account_name=$(tfStateStorageAccount)" \
        -backend-config="container_name=$(tfStateContainer)" \
        -backend-config="key=$(tfStateKey)"
  env:
    ARM_CLIENT_ID: $(ARM_CLIENT_ID)
    ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
    ARM_TENANT_ID: $(ARM_TENANT_ID)
    ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
```

**Pros:**
- Straightforward implementation
- Works well with basic pipelines
- Familiar pattern for Azure CLI users

**Cons:**
- Stores credentials in pipeline variables
- Manual credential rotation required
- Limited security controls compared to more modern approaches

**Setup Requirements:**
1. Create service principal in Azure AD
2. Store credentials as protected pipeline variables
3. Configure pipeline YAML to use Azure CLI for login

## 7. GitHub Actions with Azure Login (For GitHub Users)

**Description:** For users also using GitHub Actions, an alternative approach using the azure/login action.

**Implementation:**
```yaml
# In GitHub Actions workflow
- name: 'Az CLI login'
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

- name: 'Run Terraform'
  run: |
    cd terraform
    terraform init \
      -backend-config="resource_group_name=${{ vars.TF_STATE_RESOURCE_GROUP }}" \
      -backend-config="storage_account_name=${{ vars.TF_STATE_STORAGE_ACCOUNT }}" \
      -backend-config="container_name=${{ vars.TF_STATE_CONTAINER }}" \
      -backend-config="key=${{ vars.TF_STATE_KEY }}"
    
    terraform plan -var-file="environments/${{ vars.ENVIRONMENT }}-variables.tfvars" -out=tfplan
    terraform apply -auto-approve tfplan
  env:
    ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
    ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**Pros:**
- Native integration with GitHub Actions
- Supports OIDC workflow
- Well-documented approach for GitHub users

**Cons:**
- Only applicable for GitHub Actions users
- Different syntax and configuration than Azure DevOps

**Setup Requirements:**
1. Create appropriate GitHub repository secrets
2. Configure GitHub workflow YAML
3. Set up proper permissions for the GitHub workflow

## Recommendations

### For New Projects:
- **Workload Identity Federation (OIDC)** is the recommended approach for new projects due to its enhanced security and alignment with Zero Trust principles.

### For Existing Projects:
- If currently using service connections, consider migrating to OIDC for improved security
- For self-hosted agents on Azure VMs, Managed Identity provides the simplest and most secure option

### Security Best Practices:
- Implement least privilege access for all service principals
- Regularly rotate credentials when not using OIDC
- Use resource locks to protect critical infrastructure
- Enable monitoring and alerting for authentication activities
- Consider implementing additional governance through Azure Policy

## Setup Instructions for OIDC (Our Current Implementation)

1. **Register an Application in Azure AD:**
   - Navigate to Azure Portal > Azure Active Directory > App registrations
   - Create a new registration
   - Note the Application (client) ID and Directory (tenant) ID

2. **Configure Federated Credentials:**
   - In the registered app, go to Certificates & secrets > Federated credentials
   - Create a new federation with "Other issuer"
   - Issuer: `https://vstoken.dev.azure.com/{organization}`
   - Subject identifier: `sc://{organization}/{project}/AzureServiceConnection`
   - Name: `Azure DevOps OIDC`
   - Description: `Federated credential for Azure DevOps pipelines`

3. **Assign RBAC Permissions:**
   - Assign appropriate roles to the registered application
   - For Terraform operations, typically "Contributor" role is required
   - For state storage, ensure the application has access to the storage account

4. **Create Service Connection in Azure DevOps:**
   - Go to Project Settings > Service connections > New service connection
   - Select "Azure Resource Manager" and then "Workload Identity federation (preview)"
   - Enter the application details (Tenant ID, Subscription ID, Client ID)
   - Name the connection "AzureServiceConnection"

5. **Update Pipeline Configuration:**
   - Update the pipeline YAML to use the OIDC service connection
   - Ensure ARM_USE_OIDC is set to true
   - Set other required environment variables (ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)

## References

- [Azure OIDC with Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
- [Azure DevOps OIDC Configuration](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-openid-connect)
- [Terraform Azure Provider Authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [Azure Key Vault Integration Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/azure-key-vault?view=azure-devops&tabs=yaml) 