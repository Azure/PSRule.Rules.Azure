// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string = deployment().name

param location string = resourceGroup().location

param identityId string = '/subscriptions/nnn/resourceGroups/nnn/providers/Microsoft.ManagedIdentity/userAssignedIdentities/nnn'

param values array = [
  {
    name: 'test'
    displayName: 'Test 001'
    secretIdentifier: 'test'
  }
]

@sys.description('Create or update an APIM service.')
resource service 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    publisherEmail: ''
    publisherName: ''
  }
}

@sys.description('Configures additional named values within the service.')
resource value 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = [for item in values: {
  parent: service
  name: item.name
  properties: {
    displayName: item.?displayName ?? item.name
    secret: contains(item, 'secretIdentifier')
    value: contains(item, 'secretIdentifier') ? null : item.value
    keyVault: contains(item, 'secretIdentifier') ? {
      identityClientId: service.identity.?userAssignedIdentities[identityId].clientId
      secretIdentifier: item.secretIdentifier
    } : null
  }
}]
