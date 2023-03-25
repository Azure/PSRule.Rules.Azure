// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param names array
param location string
param ids array
param prefix string

resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (item, index) in ids: {
  scope: vault
  name: '${prefix}${names[index]}'
  properties: {
    workspaceId: ids[index]
  }
}]

resource vault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: 'vault'
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenant().tenantId
  }
}
