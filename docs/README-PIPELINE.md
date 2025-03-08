# Terraform Pipeline for Azure Infrastructure

This repository includes an Azure DevOps pipeline configuration for automating Terraform infrastructure deployments.

## Pipeline Features

- Multi-environment support (dev, staging, prod)
- Validation stage to verify Terraform configurations
- Deployment stage with approval gates
- Remote state management using Azure Storage
- Separation of plan and apply phases

## Setup Instructions

### 1. Create Azure Storage for Terraform State

Before setting up the pipeline, you need to create an Azure Storage account to store the Terraform state files.

Run the provided script:

```bash
# Make the script executable
chmod +x scripts/create-terraform-storage.sh

# Run the script
./scripts/create-terraform-storage.sh <storage_account_name> <resource_group_name> <location>

# Example
./scripts/create-terraform-storage.sh sttfstategcse rg-terraform-state eastus
```

### 2. Create Azure DevOps Service Connection

1. In your Azure DevOps project, go to Project Settings > Service Connections
2. Create a new Azure Resource Manager service connection
3. Choose the subscription where your infrastructure will be deployed
4. Name the service connection 'Azure-ServiceConnection' (or update the pipeline YAML file with your chosen name)
5. Grant access permission to all pipelines

### 3. Set Up Pipeline Variables

The pipeline uses several variables that you may need to customize:

- `terraformVersion`: The version of Terraform to use
- `backendServiceArm`: The name of your Azure service connection
- `backendAzureRmResourceGroupName`: Resource group for Terraform state storage
- `backendAzureRmStorageAccountName`: Storage account for Terraform state
- `backendAzureRmContainerName`: Blob container for Terraform state
- `backendAzureRmKey`: The key (name) of the state file

### 4. Create the Pipeline in Azure DevOps

1. In your Azure DevOps project, go to Pipelines
2. Create a new pipeline
3. Choose Azure Repos Git as the source
4. Select your repository
5. Choose "Existing Azure Pipelines YAML file"
6. Select the path to the azure-pipelines.yml file
7. Review and run the pipeline

### 5. Configure Environments

For the deployment approval process to work, you need to create environments in Azure DevOps:

1. Go to Pipelines > Environments
2. Create environments named 'dev', 'staging', and 'prod'
3. For staging and prod environments, add approval checks

## Pipeline Workflow

1. **Validate Stage**:
   - Install Terraform
   - Initialize Terraform with remote backend
   - Validate Terraform configuration
   - Create a plan and save it as an artifact

2. **Deploy Stage**:
   - Install Terraform
   - Initialize Terraform with remote backend
   - Apply the plan created in the validate stage

## Security Considerations

- The pipeline uses a service principal for authentication with Azure
- Sensitive variables should be stored as secret variables in Azure DevOps
- Approval gates can be configured for production deployments
- State files contain sensitive information; ensure storage account is properly secured

## Troubleshooting

- If the pipeline fails during Terraform init, check your backend configuration and service connection
- For validation errors, review the logs and fix any issues in your Terraform code
- If the apply fails, examine the detailed error messages in the logs 