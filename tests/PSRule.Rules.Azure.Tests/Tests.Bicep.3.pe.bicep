// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param storageAccountName string

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

resource pe 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-${storageAccountName}'
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'blobpe'
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: storage.id
        }
      }
    ]
  }
}

output nicId string = pe.properties.networkInterfaces[0].id
