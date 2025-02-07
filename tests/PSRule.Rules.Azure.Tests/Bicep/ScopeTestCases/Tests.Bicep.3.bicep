// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3237

// Based on AVM subscription placement module.

targetScope = 'tenant'

module mg './Tests.Bicep.3.child1.bicep' = {
  name: 'mg'
  scope: tenant()
}

module child './Tests.Bicep.3.child2.bicep' = {
  name: 'child'
  params: {
    managementGroups: [
      {
        id: mg.outputs.managementGroupId
        subscriptionId: mg.outputs.subscriptionId
      }
    ]
  }
}
