// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param nicId string
param storageAccountName string

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' existing = {
  name: split(nicId, '/')[8]
}

resource dns 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net/${storageAccountName}'
  properties: {
    aRecords: [
      {
        ipv4Address: nic.properties.ipConfigurations[0].properties.privateIPAddress
      }
    ]
  }
}
