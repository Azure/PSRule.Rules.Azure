// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the App Configuration Store.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The name of the configuration store replica.')
param replicaName string

@description('The location of the configuration store replica.')
param replicaLocation string

@description('The resource id of the Log Analytics workspace to send diagnostic logs to.')
param workspaceId string

@description('The name of the configuration key value.')
param configurationName string

// An example App Configuration store with a Standard SKU.
resource store 'Microsoft.AppConfiguration/configurationStores@2024-06-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}

// An example App Configuration store replica in a secondary region.
resource replica 'Microsoft.AppConfiguration/configurationStores/replicas@2024-06-01' = {
  parent: store
  name: replicaName
  location: replicaLocation
}

resource vault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: 'myKeyVault'
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' existing = {
  parent: vault
  name: 'mySecret'
}

// An example of a Key Value that holds a reference to a secret in Azure Key Vault.
resource kvReference 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-06-01' = {
  parent: store
  name: configurationName
  properties: {
    value: '{"uri":"${secret.properties.secretUri}"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

// Configure audit logs to be saved to a Log Analytics workspace.
resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: store
  name: '${name}-diagnostic'
  properties: {
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
    ]
    workspaceId: workspaceId
  }
}

@description('An App Configuration store with a replica in a secondary region.')
module br_public_store 'br/public:app/app-configuration:1.1.2' = {
  name: 'store'
  params: {
    skuName: 'Standard'
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    replicas: [
      {
        name: 'eastus'
        location: 'eastus'
      }
    ]
  }
}
