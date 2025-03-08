# Troubleshooting Guide

This guide addresses common issues you might encounter when working with the GCSE Prime EDM Terraform infrastructure.

## Table of Contents

- [Kubelogin Issues](#kubelogin-issues)
  - [Missing kubelogin tool](#missing-kubelogin-tool)
  - [kubelogin conversion error](#kubelogin-conversion-error)
  - [Token expired or invalid](#token-expired-or-invalid)
- [Terraform Authentication Issues](#terraform-authentication-issues)
  - [Service Connection Errors](#service-connection-errors)
  - [OIDC Authentication Errors](#oidc-authentication-errors)
- [Pipeline Issues](#pipeline-issues)
  - [Variable Group Access](#variable-group-access)
  - [Missing Resources](#missing-resources)
- [General Troubleshooting](#general-troubleshooting)

## Kubelogin Issues

### Missing kubelogin tool

**Error:**
```
Error: Error building AzureRM Client: obtain Azure CLI token: Error parsing json result from the Azure CLI: Error waiting for the Azure CLI: exit status 1: ERROR: Please run 'az aks install-cli' to install kubelogin.
```

**Solution:**
Install kubelogin based on your operating system:

**For macOS:**
```bash
brew install Azure/kubelogin/kubelogin
```

**For Windows:**
```bash
az aks install-cli
```

**For Linux:**
```bash
curl -LO https://github.com/Azure/kubelogin/releases/download/v0.0.24/kubelogin-linux-amd64.zip
unzip kubelogin-linux-amd64.zip
sudo mv bin/linux_amd64/kubelogin /usr/local/bin/
rm -rf bin/ kubelogin-linux-amd64.zip
```

### kubelogin conversion error

**Error:**
```
Error: Failed to run conversion v1.24.9: failed to create cluster client: converting kubeconfig: exec: executable kubelogin not found
```

**Solution:**
- Ensure kubelogin is installed and in your PATH
- Verify the AKS version is compatible with your installed kubelogin version
- Try running `az aks get-credentials` again to refresh your kubeconfig

### Token expired or invalid

**Error:**
```
Error: Error retrieving az AKS credentials: The access token is invalid. Token might have expired.
```

**Solution:**
- Run `az login` to refresh your Azure CLI credentials
- Run `az account set --subscription "Your-Subscription-ID"` to set the correct subscription
- Try running `az aks get-credentials` again to refresh your credentials

## Terraform Authentication Issues

### Service Connection Errors

**Error:**
```
Error: Azure Resource Manager Provider authorization failed. Please check your Service Connection permissions.
```

**Solution:**
- Verify the service principal used by the service connection has proper permissions
- Check that the service connection secret has not expired
- Ensure the service connection is authorized for the pipeline

### OIDC Authentication Errors

**Error:**
```
Error: Failed to get OIDC token: ManagedIdentityCredential authentication failed
```

**Solution:**
- Verify your OIDC configuration in Azure AD
- Check that the federated credential subject format matches exactly what Azure DevOps expects:
  - Format should be: `sc://{organization}/{project}/{service-connection-name}`
- Ensure the OIDC issuer URL is correct: `https://vstoken.dev.azure.com/{organization}`

**Error:**
```
Error: Failed to perform requested operation on AAD Graph service. Retry after delay. Activity ID: [GUID]
```

**Solution:**
- The Azure AD application registration might not have propagated yet
- Wait a few minutes and try again
- Check that your application has appropriate permissions

**Error:**
```
Error: Error deploying ARM Template: AuthorizationFailed: The client '[CLIENT_ID]' with object id '[OBJECT_ID]' does not have authorization to perform action
```

**Solution:**
- Verify the RBAC permissions assigned to your application
- Ensure the application has appropriate roles (e.g., Contributor) for the resources you're managing
- For state storage access, ensure the app has Storage Blob Data Contributor role

## Pipeline Issues

### Variable Group Access

**Error:**
```
Error: The pipeline is not authorized to use variable group: [GROUP_NAME]
```

**Solution:**
- Go to the variable group in Azure DevOps
- Click on 'Pipeline permissions'
- Grant permissions to the pipeline where it's needed

### Missing Resources

**Error:**
```
Error: creating [Resource]: unexpected response: StatusCode=404
```

**Solution:**
- Verify resource names and references are correct
- Check if the parent resources (like resource groups) have been successfully created
- Ensure the current identity has permissions to view/create the resource

## General Troubleshooting

### Terraform State Lock Issues

**Error:**
```
Error: Error acquiring the state lock
```

**Solution:**
- Wait a few minutes for any running operations to complete
- If no operations are running, unlock the state:
  ```bash
  terraform force-unlock [LOCK_ID]
  ```

### Network Configuration Issues

**Error:**
```
Error: provisioning [Resource]: network.InterfacesClient#CreateOrUpdate: Failure sending request: StatusCode=400
```

**Solution:**
- Verify subnet configurations, address spaces, and network security groups
- Ensure there are no IP address conflicts
- Check for subnet delegation conflicts

### Missing Provider Registration

**Error:**
```
Error: Resource Provider not registered: Microsoft.XYZ
```

**Solution:**
- Register the required provider:
  ```bash
  az provider register --namespace Microsoft.XYZ
  ```

## Azure DevOps Pipeline-Specific Issues

### OIDC Variable Setup Issues

**Error:**
```
Error: ##[error]The AZURE_TENANT_ID variable is not set.
```

**Solution:**
- Ensure your variable group contains all required variables (`clientId`, `tenantId`, `subscriptionId`)
- Verify the variable group is properly referenced in your pipeline YAML
- Check that environment-specific variable groups are configured correctly

### ARM_* Environment Variables Not Set

**Error:**
```
Error: No credentials config could be discovered
```

**Solution:**
- Make sure your pipeline sets the necessary environment variables:
  - ARM_USE_OIDC=true
  - ARM_CLIENT_ID=$(clientId)
  - ARM_TENANT_ID=$(tenantId)
  - ARM_SUBSCRIPTION_ID=$(subscriptionId)
- Verify the AzureCLI task that sets these variables runs before Terraform commands

### Service Connection Not Found

**Error:**
```
Error: ##[error]The service connection with name "SC-GCSE-PrimeEDM-OIDC" could not be found.
```

**Solution:**
- Verify the service connection name in your pipeline matches exactly the one in Azure DevOps
- Check the service connection exists and is accessible to the pipeline
- Ensure the service connection is not disabled 