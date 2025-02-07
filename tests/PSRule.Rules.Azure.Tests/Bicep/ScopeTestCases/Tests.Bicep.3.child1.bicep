// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'tenant'

resource managementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-test'
  properties: {
    displayName: 'Test Management Group'
    details: {
      parent: {
        id: ''
      }
    }
  }
}

output managementGroupId string = managementGroup.id
output subscriptionId string = '00000000-0000-0000-0000-000000000000'
