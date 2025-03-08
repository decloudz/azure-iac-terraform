#!/bin/bash
# Script to help set up Azure DevOps variable groups for Terraform variables
# This script reads the variables from your .tfvars files and generates az CLI commands
# to create variable groups and add variables to them.

set -e

# Configuration
ORGANIZATION="https://dev.azure.com/az-msops"
PROJECT="GCSE"
COMMON_GROUP="GCSE-PrimeEDM-Common"
DEV_GROUP="GCSE-PrimeEDM-Dev"
STAGING_GROUP="GCSE-PrimeEDM-Staging"
PROD_GROUP="GCSE-PrimeEDM-Prod"

# Function to extract variables from tfvars file
extract_variables() {
  local file=$1
  echo "Extracting variables from $file..."
  grep -v "^#" "$file" | grep "=" | sed 's/ *= */=/g' | sed 's/"//g' | sed "s/'//g"
}

# Function to create a variable group
create_variable_group() {
  local group_name=$1
  local description=$2
  
  echo "Creating variable group: $group_name"
  echo "az pipelines variable-group create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --name \"$group_name\" --description \"$description\" --variables placeholder=true"
}

# Function to add a variable to a group
add_variable() {
  local group_name=$1
  local var_name=$2
  local var_value=$3
  local is_secret=$4
  
  if [ "$is_secret" = "true" ]; then
    echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$group_name\" --name \"$var_name\" --value \"$var_value\" --secret"
  else
    echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$group_name\" --name \"$var_name\" --value \"$var_value\""
  fi
}

# List of sensitive variable names that should be marked as secret
declare -a SENSITIVE_VARS=("postgresql_admin_password" "client_secret" "ssh_public_key" "admin_password")

# Identify if a variable is sensitive
is_sensitive() {
  local var_name=$1
  for sensitive_var in "${SENSITIVE_VARS[@]}"; do
    if [[ "$var_name" == *"$sensitive_var"* ]]; then
      return 0
    fi
  done
  return 1
}

# List of common variables that should go in the common group
declare -a COMMON_VARS=("project" "owner" "cost_center" "vnet_address_space" "subnet_prefixes" "subnet_names" 
                        "cert_manager_namespace" "cert_manager_identity_name" "external_dns_namespace" 
                        "external_dns_identity_name" "key_vault_sku" "tenant_id" "client_id" "subscription_id")

# Check if a variable should be in the common group
is_common() {
  local var_name=$1
  for common_var in "${COMMON_VARS[@]}"; do
    if [[ "$var_name" == "$common_var" ]]; then
      return 0
    fi
  done
  return 1
}

# Generate create group commands
echo "# Commands to create variable groups"
create_variable_group "$COMMON_GROUP" "Common variables for all environments"
create_variable_group "$DEV_GROUP" "Development environment variables"
create_variable_group "$STAGING_GROUP" "Staging environment variables"
create_variable_group "$PROD_GROUP" "Production environment variables"
echo ""

# Process dev variables
if [ -f "environments/dev.tfvars" ]; then
  echo "# Commands to add variables from dev environment"
  
  while IFS= read -r line; do
    var_name=$(echo $line | cut -d'=' -f1 | tr -d ' ')
    var_value=$(echo $line | cut -d'=' -f2- | tr -d ' ')
    
    # Check if variable should be treated as sensitive
    if is_sensitive "$var_name"; then
      if is_common "$var_name"; then
        echo "# WARNING: Sensitive variable '$var_name' is marked as common. Consider if this is appropriate."
        add_variable "$COMMON_GROUP" "$var_name" "<REPLACE_WITH_ACTUAL_VALUE>" "true"
      else
        add_variable "$DEV_GROUP" "$var_name" "<REPLACE_WITH_ACTUAL_VALUE>" "true"
      fi
    else
      if is_common "$var_name"; then
        add_variable "$COMMON_GROUP" "$var_name" "$var_value" "false"
      else
        add_variable "$DEV_GROUP" "$var_name" "$var_value" "false"
      fi
    fi
  done < <(extract_variables "environments/dev-variables.tfvars")
  
  echo ""
fi

# Guidance on what to modify for staging and prod
echo "# For staging and production environments:"
echo "# 1. Create appropriate tfvars files (environments/staging-variables.tfvars, environments/prod-variables.tfvars)"
echo "# 2. Run this script again, adjusting the variable group names"
echo "# 3. For production-specific settings, review variables carefully"
echo ""

# Special variables needed for the pipeline
echo "# Additional special variables needed for the pipeline"
echo "# These might not be in your tfvars files but are required by the pipeline:"

# For common group
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$COMMON_GROUP\" --name \"createK8sResources\" --value \"true\""
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$COMMON_GROUP\" --name \"createFederatedIdentity\" --value \"true\""
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$COMMON_GROUP\" --name \"createWildcardRecord\" --value \"false\""
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$COMMON_GROUP\" --name \"aks_admin_username\" --value \"azureuser\""
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$COMMON_GROUP\" --name \"logAnalyticsRetentionDays\" --value \"30\""

# Environment-specific
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$DEV_GROUP\" --name \"aksNodeCount\" --value \"2\""
echo "az pipelines variable-group variable create --organization \"$ORGANIZATION\" --project \"$PROJECT\" --group-id \"$DEV_GROUP\" --name \"aksMaxPods\" --value \"30\""

echo ""
echo "# Remember to update placeholders (like <REPLACE_WITH_ACTUAL_VALUE>) with actual values"
echo "# For sensitive variables, consider using the Azure DevOps web interface instead of this script" 