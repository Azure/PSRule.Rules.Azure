// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the Storage Account.')
param name string

@description('The Azure location to deploy resources.')
param location string = resourceGroup().location

// An example Storage Account
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
}
