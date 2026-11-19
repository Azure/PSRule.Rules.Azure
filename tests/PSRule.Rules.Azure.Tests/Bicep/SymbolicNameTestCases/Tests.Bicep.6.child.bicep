// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

// Child module that returns an object typed output containing a resource id.
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid('policyReader', managementGroup().id)
  properties: {
    roleName: 'Policy Reader'
    description: 'Read only access to policy.'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.Authorization/policyAssignments/read'
        ]
      }
    ]
    assignableScopes: [
      managementGroup().id
    ]
  }
}

output policyReader object = {
  id: roleDefinition.id
  name: roleDefinition.name
}
