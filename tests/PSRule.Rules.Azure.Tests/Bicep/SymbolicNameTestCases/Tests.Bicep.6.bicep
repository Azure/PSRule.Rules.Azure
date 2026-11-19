// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

resource intermediateRoot 'Microsoft.Management/managementGroups@2023-04-01' = {
  scope: tenant()
  name: 'mg-intermediate-root'
  properties: {
    displayName: 'Intermediate Root'
  }
}

// A string sourced from an object typed module output must resolve to a string when
// passed into a nested deployment and consumed by guid().
module customRoles './Tests.Bicep.6.child.bicep' = {
  name: 'customRoles'
  scope: intermediateRoot
}

module roleAssignments './Tests.Bicep.6.assignments.bicep' = {
  name: 'roleAssignments'
  scope: intermediateRoot
  params: {
    roleAssignments: [
      {
        principalId: '00000000-0000-0000-0000-000000000001'
        roleDefinitionId: customRoles.outputs.policyReader.id
      }
      {
        principalId: '00000000-0000-0000-0000-000000000002'
        roleDefinitionId: customRoles.outputs.policyReader.id
      }
    ]
  }
}
