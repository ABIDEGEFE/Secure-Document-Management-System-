#!/bin/bash

# Variables
RESOURCE_GROUP="SecureDocRG3"
LOCATION="eastus"
STORAGE_ACCOUNT_NAME="securedocs665d06"
VNET_NAME="SecureVNet"
SUBNET_NAME="SecureSubnet"
VM_NAME="SecureVM"
CONTAINER_NAME="securefiles"

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Storage Account with CMK encryption and Private Access
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_GRS \
    --kind StorageV2 \
    --access-tier Hot \
    --allow-blob-public-access false  # No public access

# Create Virtual Network & Subnet
az network vnet create \
    --name $VNET_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --address-prefixes 10.0.0.0/16 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefixes 10.0.1.0/24

# Create a Virtual Machine in the VNet to Access Storage
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image Win2019Datacenter \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET_NAME \
    --admin-username "Abinet" \
    --admin-password "ABne665506**" \
    

# Create a Blob Container in Storage Account
STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query '[0].value' --output tsv)

az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --public-access off  # Private container

echo "Storage account '$STORAGE_ACCOUNT_NAME' created with Private Endpoint. VM '$VM_NAME' can access the storage securely."
