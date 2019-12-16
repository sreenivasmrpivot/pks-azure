#!/bin/bash

# set -eux

# Set Azure cloud name
az cloud set --name $CLOUD_NAME

# Login to Azure from cli using userid and password
az login -u $AZURE_USERNAME -p $AZURE_PASSWORD

# get account list
az account list > acclst.json

AZURE_SUBSCRIPTION_ID=$(jq -r '.[] | select(.name=="Labs-srajaram") | .id' acclst.json) 
TENANT_ID=$(jq -r '.[] | select(.name=="Labs-srajaram") | .tenantId' acclst.json)
# rm acclst.json

# Set subscription
az account set --subscription $AZURE_SUBSCRIPTION_ID

# Create Service Account
az ad app create --display-name "Principal for BOSH $DEPLOYMENT_NAME" \
--password $BOSH_SERVICE_ACCOUNT_PASSWORD --homepage "http://BOSHAzureCPI$DEPLOYMENT_NAME" \
--identifier-uris "http://BOSHAzureCPI$DEPLOYMENT_NAME" > adapp.json

# Read APP_ID
APP_ID=$(jq -r .appId adapp.json)
# rm adapp.json

# Create and Configure a Service Principal
az ad sp create --id $APP_ID

# Add Owner permission
az role assignment create --assignee $APP_ID \
--role "Owner" --scope /subscriptions/$AZURE_SUBSCRIPTION_ID

# Verify Role assignments
az role assignment list --assignee $APP_ID

# Verify Your Service Principal
az login --username $APP_ID --password $BOSH_SERVICE_ACCOUNT_PASSWORD \
--service-principal --tenant $TENANT_ID 

# Perform Registrations
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
