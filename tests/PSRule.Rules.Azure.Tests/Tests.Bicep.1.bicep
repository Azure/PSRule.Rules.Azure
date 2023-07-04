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

@description('A reference to an example VNET.')
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: 'vnet-001'
}

@description('A reference to an exampe subnet.')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'subnet-001'
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

resource endpoint 'Microsoft.Network/privateEndpoints@2020-03-01' = {
  location: location
  name: 'pe-${name}'
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'default'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

@description('A unique resource Id for the storage account.')
output id string = storageAccount.id

@description('Any tags set on the storage account.')
output tags object = storageAccount.tags

@description('A unique string that is generated from the blob endpoint.')
output unique string = uniqueString(storageAccount.properties.primaryEndpoints.blob)

@description('The endpoint of the storage account.')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('A container endpoint.')
#disable-next-line prefer-interpolation
output containerEndpoint string = concat(storageAccount.properties.primaryEndpoints.blob, '/container')

@description('A value for testing that does not exist.')
#disable-next-line prefer-interpolation BCP053
output unknownValue string = concat(storageAccount.properties.unknownValue, '/container')

@description('The ID of the endpoint NIC.')
output endpointNIC string = endpoint.properties.networkInterfaces[0].id
