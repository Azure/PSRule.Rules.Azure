// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param principalId string

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId)
  properties: {
    principalId: principalId
    roleDefinitionId: '8a869b90-6d6c-4307-9d0f-22dbc136ccd9'
    principalType: 'ServicePrincipal'
    description: 'Test role assignment for checking scope and ID.'
  }
}
