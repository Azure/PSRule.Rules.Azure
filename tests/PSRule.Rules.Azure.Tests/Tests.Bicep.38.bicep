// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2850

// Handle from subscription scope.
targetScope = 'subscription'

param location string = deployment().location

module site './Tests.Bicep.38.site.bicep' = {
  name: 'site'
  scope: resourceGroup('rg2')
  params: {
    name: 'app'
    location: location
    identityId: identity.outputs.id
  }
}

module identity './Tests.Bicep.38.child.bicep' = {
  name: 'mi'
  scope: resourceGroup('rg1')
  params: {
    name: 'mi'
    location: location
  }
}
