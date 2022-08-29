// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location
param sku string = 'Standard_LRS'
param tlsVersion string = 'TLS1_2'
param publicAccess bool = false

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'storage01'
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: tlsVersion
    allowBlobPublicAccess: publicAccess ? true : null
  }
}
