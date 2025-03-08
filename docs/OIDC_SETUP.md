# Setting Up OIDC Authentication for Azure DevOps Pipelines

This guide provides step-by-step instructions for setting up OpenID Connect (OIDC) authentication between Azure DevOps and Azure for Terraform pipelines. OIDC authentication eliminates the need to store credentials and follows Zero Trust security principles.

## Prerequisites

- Azure subscription with Owner or Contributor permissions
- Azure DevOps organization and project with administrative access
- Terraform configured for Azure deployment

## Step 1: Register an Application in Azure AD

1. Sign in to the [Azure Portal](https://portal.azure.com).
2. Navigate to **Azure Active Directory** > **App registrations**.
3. Click **+ New registration**.
4. Enter the following information:
   - **Name**: `GCSE-PrimeEDM-OIDC`
   - **Supported account types**: Accounts in this organizational directory only (single tenant)
   - **Redirect URI**: Leave blank
5. Click **Register**.
6. Once created, make note of the following values (you'll need these later):
   - **Application (client) ID**
   - **Directory (tenant) ID**

## Step 2: Configure Federated Credentials

1. In your newly registered application, go to **Certificates & secrets** in the left navigation.
2. Select the **Federated credentials** tab.
3. Click **+ Add credential**.
4. Select **Other issuer** as the scenario.
5. Fill in the following details:
   - **Issuer**: `https://vstoken.dev.azure.com/{YourOrganizationName}`
   - **Subject identifier**: `sc://{YourOrganizationName}/{YourProjectName}/AzureServiceConnection`
     - Replace `{YourOrganizationName}` and `{YourProjectName}` with your actual organization and project names
   - **Name**: `AzureDevOps-OIDC`
   - **Description**: `Federated credential for Azure DevOps pipelines`
6. Click **Add**.

## Step 3: Assign RBAC Permissions

1. Navigate to your Azure subscription in the Azure Portal.
2. Go to **Access control (IAM)**.
3. Click **+ Add** > **Add role assignment**.
4. In the **Role** tab, select **Contributor** (or a more limited role if you prefer).
5. In the **Members** tab:
   - Select **User, group, or service principal**
   - Click **+ Select members**
   - Search for your application (`GCSE-PrimeEDM-OIDC`) and select it
   - Click **Select**
6. Click **Review + assign** to complete the assignment.

### Additional RBAC for State Storage

If your Terraform state is stored in Azure Blob Storage, you also need to assign permissions to the storage account:

1. Navigate to your Terraform state storage account.
2. Go to **Access control (IAM)**.
3. Click **+ Add** > **Add role assignment**.
4. Assign the **Storage Blob Data Contributor** role to your application.

## Step 4: Create a Service Connection in Azure DevOps

1. In Azure DevOps, navigate to your project.
2. Go to **Project settings** > **Service connections**.
3. Click **New service connection**.
4. Select **Azure Resource Manager**.
5. Choose **Workload Identity federation (preview)** as the authentication method.
6. Fill in the details:
   - **Subscription**: Select your Azure subscription
   - **Resource Group**: Leave empty (or scope to a specific resource group if needed)
   - **Tenant ID**: Enter your Directory (tenant) ID
   - **Service connection name**: `AzureServiceConnection`
   - **Grant access permission to all pipelines**: Check this if you want all pipelines to be able to use this connection
7. Click **Save**.

## Step 5: Configure Pipeline Variables

For the OIDC authentication to work properly, you need to store certain variables in Azure DevOps variable groups:

1. In Azure DevOps, navigate to **Pipelines** > **Library**.
2. Create or edit the variable groups mentioned in your pipeline YAML (e.g., `GCSE-PrimeEDM-Common`).
3. Add the following variables:
   - `clientId`: The Application (client) ID from Step 1
   - `tenantId`: The Directory (tenant) ID from Step 1
   - `subscriptionId`: Your Azure subscription ID

## Step 6: Update Your Pipeline YAML

Your `azure-pipelines.yml` should already be configured for OIDC authentication. The key sections include:

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

# Using environment variables in subsequent tasks
- task: Bash@3
  displayName: 'Terraform Commands'
  inputs:
    targetType: 'inline'
    script: |
      # Terraform commands here
  env:
    ARM_USE_OIDC: $(ARM_USE_OIDC)
    ARM_CLIENT_ID: $(ARM_CLIENT_ID)
    ARM_TENANT_ID: $(ARM_TENANT_ID)
    ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
```

## Step 7: Run and Verify the Pipeline

1. Commit and push your updated pipeline YAML.
2. Run the pipeline manually or trigger it with a new commit.
3. Verify that the pipeline successfully authenticates to Azure using OIDC.

## Troubleshooting

### Common Issues

#### Error: "ManagedIdentityCredential authentication failed"

This usually means the OIDC setup is not complete or has configuration issues.

**Solution:**
- Verify the federated credential is configured correctly in Azure AD
- Ensure the subject identifier in the federated credential matches exactly with your Azure DevOps organization/project/service connection

#### Error: "insufficient privileges to complete the operation"

This indicates that the Azure AD application lacks the necessary permissions.

**Solution:**
- Review RBAC assignments for the application
- Ensure the application has appropriate roles for all resources it needs to access

#### Error in AzureCLI task failing to set variables

**Solution:**
- Check the variable group configuration
- Ensure all required variables (`clientId`, `tenantId`, `subscriptionId`) are defined
- Verify the service connection name matches what's in Azure DevOps

#### Error: "Variable group was not found or is not authorized for use"

**Solution:**
- Ensure all variable groups referenced in your pipeline exist
- Verify the pipeline has permission to access the variable groups
- Check that the variable group names match exactly what's in your pipeline YAML

## Security Considerations

- Regularly review the permissions assigned to the application
- Use the least privilege principle - only assign the roles that are absolutely necessary
- Consider using resource-specific roles instead of broad roles like Contributor
- Monitor the activity logs for the application to detect any unusual patterns

## References

- [Azure OIDC with Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
- [Azure AD Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [Azure DevOps Service Connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops)
- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) 