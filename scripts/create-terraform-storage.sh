#!/bin/bash

# Script to create Azure Storage for Terraform state management
# Usage: ./create-terraform-storage.sh <storage_account_name> <resource_group_name> <location>

set -e

# Check if the required parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <storage_account_name> <resource_group_name> <location>"
    echo "Example: $0 mystorageaccount myresourcegroup eastus"
    exit 1
fi

STORAGE_ACCOUNT_NAME=$1
RESOURCE_GROUP_NAME=$2
LOCATION=$3
CONTAINER_NAME="tfstate"

# Check if resource group exists, create if it doesn't
if ! az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "Creating resource group '$RESOURCE_GROUP_NAME' in location '$LOCATION'..."
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
else
    echo "Resource group '$RESOURCE_GROUP_NAME' already exists."
fi

# Check if storage account exists, create if it doesn't
if ! az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "Creating storage account '$STORAGE_ACCOUNT_NAME'..."
    az storage account create \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --location "$LOCATION" \
        --sku "Standard_LRS" \
        --kind "StorageV2" \
        --https-only true \
        --min-tls-version "TLS1_2"
else
    echo "Storage account '$STORAGE_ACCOUNT_NAME' already exists."
fi

# Get storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query "[0].value" -o tsv)

# Check if container exists, create if it doesn't
if ! az storage container show \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$STORAGE_ACCOUNT_KEY" \
    --name "$CONTAINER_NAME" &> /dev/null; then
    echo "Creating storage container '$CONTAINER_NAME'..."
    az storage container create \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --account-key "$STORAGE_ACCOUNT_KEY" \
        --name "$CONTAINER_NAME"
else
    echo "Storage container '$CONTAINER_NAME' already exists."
fi

echo ""
echo "Azure Storage configured successfully for Terraform state:"
echo "Resource Group:   $RESOURCE_GROUP_NAME"
echo "Storage Account:  $STORAGE_ACCOUNT_NAME"
echo "Container:        $CONTAINER_NAME"
echo ""
echo "Configuration for terraform backend:"
echo "resource_group_name  = \"$RESOURCE_GROUP_NAME\""
echo "storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "container_name       = \"$CONTAINER_NAME\""
echo "key                  = \"terraform.tfstate\"" 