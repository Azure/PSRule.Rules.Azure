// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'subscription'

param config object = loadJsonContent('Tests.Bicep.10.content.json')
param location string = config.location
param resourceGroups array = config.resourceGroups

module resourceGroup 'Tests.Bicep.10.child.bicep' = [for resourceGroup in resourceGroups: {
  scope: subscription()
  name: '${resourceGroup}-deploy'
  params: {
    name: resourceGroup
    location: location
  }
}]
