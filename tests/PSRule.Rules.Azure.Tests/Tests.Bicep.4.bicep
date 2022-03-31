// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

module mi './Tests.Bicep.4.id.bicep' = {
  name: 'mi'
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: '${guid(resourceGroup().id)}'
  properties: {
    principalId: mi.outputs.clientId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  }
}

var resourceGroupName = 'other-rg'

module kv './Tests.Bicep.4.vault.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'kv'
}
