# Setting Up OIDC Authentication with Azure for GitHub Actions

This guide will help you set up OpenID Connect (OIDC) authentication between GitHub Actions and Azure, which provides more secure authentication without storing long-lived credentials.

## Prerequisites

- Azure subscription
- Administrator access to Azure AD
- Owner or User Access Administrator role on the target subscription
- GitHub repository where you want to deploy resources

## Step 1: Create or Update Azure AD Application

1. Sign in to the [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **App registrations**
3. Create a new registration or use an existing one (like your `jenkins-terraform` app):
   - Name: `GitHub-Actions-OIDC` (or use existing app)
   - Supported account types: Accounts in this organizational directory only
   - Redirect URI: Leave blank
   - Click **Register**

## Step 2: Configure Federated Identity Credentials

For your specific configuration, you need to create credentials that match what GitHub Actions is sending.

### For the Environment-based Deployment (Your Current Error)

1. In your App registration, go to **Certificates & secrets**
2. Select the **Federated credentials** tab
3. Click **Add credential**
4. Select the **GitHub Actions deploying Azure resources** scenario
5. Fill in the following details:
   - **Organization name**: `decloudz` (your GitHub organization)
   - **Repository name**: `azure-iac-terraform` (your repository name)
   - **Entity type**: `Environment`
   - **Environment name**: `dev` (exactly as configured in your workflow)
   - **Name**: `github-actions-oidc-dev-environment`
6. Click **Add**

### For Branch-based Deployment (Additional Setup)

Repeat the process but with these settings:
1. **Entity type**: `Branch`
2. **GitHub branch name**: `main`
3. **Name**: `github-actions-oidc-main-branch`

### For Pull Request-based Operations (Optional)

If you need to run operations from pull requests:
1. **Entity type**: `Pull request`
2. **Name**: `github-actions-oidc-pull-requests`

## Important: The Exact Subject Format

The error you received shows exactly what subject format GitHub is sending:
```
repo:decloudz/azure-iac-terraform:environment:dev
```

Your federated identity credential **subject** field must match this exactly. When using the Azure Portal's UI, it will format it correctly if you use the dedicated GitHub Actions scenario.

## Step 3: Assign Permissions to the Application

1. Go to your Azure subscription
2. Navigate to **Access control (IAM)**
3. Click **Add** > **Add role assignment**
4. Select the **Contributor** role (or a more specific role if you prefer)
5. In the **Members** tab, select **User, group, or service principal**
6. Click **Select members**
7. Search for your application name and select it
8. Click **Review + assign**

## Step 4: Store Application Details as GitHub Secrets

1. In your GitHub repository, go to **Settings** > **Secrets and variables** > **Actions**
2. Add the following secrets:
   - `AZURE_CLIENT_ID`: The Application (client) ID of your App registration
   - `AZURE_TENANT_ID`: Your Azure AD tenant ID
   - `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

## Step 5: Update GitHub Actions Workflow

Ensure your workflow has the following configurations:

```yaml
permissions:
  contents: read
  id-token: write # Required for OIDC authentication with Azure
```

And the login step:

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    audience: api://AzureADTokenExchange
```

## Step 6: Define GitHub Environments (If Using Environment Authentication)

Since you're seeing an error related to the `environment:dev` subject, you need to set up environments in GitHub:

1. Go to your repository on GitHub
2. Click on **Settings** > **Environments**
3. Click **New environment**
4. Name it `dev` (exactly as referenced in your workflow)
5. Configure any environment protection rules you need
6. Click **Configure environment**

Repeat for any other environments you need (`staging`, `prod`, etc.)

## Troubleshooting

If you see the error `No matching federated identity record found for presented assertion subject`:
- This means the subject sent by GitHub doesn't match what's configured in Azure AD
- The error shows exactly what subject is being sent (e.g., `repo:decloudz/azure-iac-terraform:environment:dev`)
- Create a new federated credential with exactly that subject pattern
- Make sure you've created the GitHub environment if using environment-based authentication

If you see permission errors:
- Verify the `id-token: write` permission is set in the workflow
- Make sure the App has the necessary role assignments in Azure

## References

- [Azure Login Action documentation](https://github.com/Azure/login)
- [Microsoft documentation on Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [GitHub documentation on Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) 