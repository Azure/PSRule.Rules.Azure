// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the Storage Account.')
param name string

@description('The Azure location to deploy resources.')
param location string = resourceGroup().location

@description('One or more tags to use.')
param tags object = {
  env: 'test'
}

@description('An example Storage Account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
  tags: tags
}

@description('A unique resource Id for the storage account.')
output id string = storageAccount.id

@description('Any tags set on the storage account.')
output tags object = storageAccount.tags
