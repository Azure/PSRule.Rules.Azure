// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param value3 array
param value4 array
param staticIP string

module child 'Tests.Bicep.11.child.child.bicep' = {
  name: 'child2'
  params: {
    value5: [
      {
        value6: [for item in value3: {
          id: item.id
        }]
        value7: [for item in value4: {
          id: item.id
        }]
        privateIPAllocationMethod: !empty(staticIP) ? 'Static' : 'Dynamic'
        staticPublicIP: staticIP
      }
    ]
  }
}
