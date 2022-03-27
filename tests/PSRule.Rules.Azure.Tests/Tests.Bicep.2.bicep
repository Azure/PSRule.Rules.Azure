// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the first Storage Account.')
param storageName1 string = 'sabicep001'

@description('The name of the second Storage Account.')
param storageName2 string = 'sabicep002'

param location string = resourceGroup().location

module storage3 './Tests.Bicep.1.bicep' = {
  name: 'storage3'
  params: {
    name: '${split(storage1.outputs.id, '/')[8]}${storage1.outputs.unique}'
    location: location
    tags: storage1.outputs.tags
  }
}

module storage1 './Tests.Bicep.1.bicep' = {
  name: 'storage1'
  params: {
    name: storageName1
    location: location
  }
}

module storage2 './Tests.Bicep.1.bicep' = {
  name: 'storage2'
  params: {
    name: storageName2
    location: location
    tags: storage1.outputs.tags
  }
}
