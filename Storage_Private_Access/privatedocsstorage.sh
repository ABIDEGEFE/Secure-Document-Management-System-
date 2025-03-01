#!/bin/bash

# Variables
RESOURCE_GROUP="SecureDocRG2"
STORAGE_ACCOUNT_NAME="privatedocs665d06"  # Ensures uniqueness
LOCATION="eastus"
CONTAINER_NAME="privatedocs"

# Create Resource Group (if not exists)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Storage Account with LRS
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --access-tier Hot

# Get Storage Account Key
STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query '[0].value' --output tsv)

# Create Blob Container with Private Access (No Anonymous Access)
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --public-access off

# Enable Soft Delete for Blob Recovery
az storage blob service-properties delete-policy update \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --enable true --days-retained 7

# Apply Legal Hold Policy (Immutability)
az storage container legal-hold set \
    --account-name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --container-name $CONTAINER_NAME \
    --tags "Confidential" "DoNotDelete"

echo "Storage account '$STORAGE_ACCOUNT_NAME' created with private container '$CONTAINER_NAME'. Soft delete and legal hold applied."
  