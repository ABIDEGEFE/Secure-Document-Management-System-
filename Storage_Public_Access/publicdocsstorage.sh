#!/bin/bash

RESOURCE_GROUP="SecureDocRG1"
LOCATION="eastus"
STORAGE_ACCOUNT_NAME="publicdocs665d06"
CONTAINER_NAME="publicfiles"

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Storage Account (Public Access)
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access true

# Wait for Storage Account to be Ready
echo "Waiting 10 seconds for storage account readiness..."
sleep 10

# Retrieve Storage Key
STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query '[0].value' --output tsv)

echo "Storage Key: $STORAGE_KEY"

# Verify Key Retrieval
if [[ -z "$STORAGE_KEY" ]]; then
    echo "Failed to retrieve storage key. Exiting..."
    exit 1
fi

# Create a Blob Container
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --public-access container


# After uploading the blob on the current dirctory, use the following command to upload on the container
az storage blob upload \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --container-name $CONTAINER_NAME \
    --file /path/to/file \
    --name "blob name"