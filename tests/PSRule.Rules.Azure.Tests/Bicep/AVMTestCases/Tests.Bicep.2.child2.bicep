// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: 'storage1'
}

resource site 'Microsoft.Web/sites@2024-04-01' = {
  name: 'site1'
  location: 'eastus'
  kind: 'web'
  properties: {
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'endpoint'
          value: storage.properties.primaryEndpoints.blob
        }
      ]
    }
  }
}
