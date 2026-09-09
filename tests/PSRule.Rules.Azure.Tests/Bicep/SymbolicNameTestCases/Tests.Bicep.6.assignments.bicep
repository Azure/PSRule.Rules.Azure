// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

type roleAssignmentInput = {
  principalId: string
  roleDefinitionId: string
}

param roleAssignments roleAssignmentInput[]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(managementGroup().id, assignment.principalId, assignment.roleDefinitionId)
    properties: {
      principalId: assignment.principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: assignment.roleDefinitionId
    }
  }
]
