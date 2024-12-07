// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'subscription'

param location string = deployment().location

@description('')
param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'rg-1'
  location: location
  tags: tags
}

module id './Tests.Bicep.2.child2.bicep' = {
  scope: rg
  name: 'id-deploy'
  params: {
    name: 'id-1'
    location: location
    tags: tags
  }
}

module registry './Tests.Bicep.2.child1.bicep' = {
  scope: rg
  name: 'registry-deploy'
  params: {
    location: location
    name: 'registry-1'
    tags: tags
    identityId: id.outputs.id
  }
}

output userAssignedIdentityId string = id.outputs.id
output registryId string = registry.outputs.id
