// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'subscription'

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: '48d15605-70a3-4676-bb6a-792f403786b5'
  properties: {
    principalId: '48d15605-70a3-4676-bb6a-792f403786b5'
    roleDefinitionId: '48d15605-70a3-4676-bb6a-792f403786b5'
    principalType: 'ServicePrincipal'
    description: 'Test role assignment for checking scope and ID.'
  }
}
