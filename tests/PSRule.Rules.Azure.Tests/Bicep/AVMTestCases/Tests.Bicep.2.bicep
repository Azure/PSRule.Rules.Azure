// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

module child1 'Tests.Bicep.2.child1.bicep' = {
  name: 'child1'
}

module child2 'Tests.Bicep.2.child2.bicep' = {
  name: 'child2'
  dependsOn: [
    child1
  ]
}
