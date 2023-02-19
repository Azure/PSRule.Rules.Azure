// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param resourceName string = 'cosmos-repro'
param servicePrincipalIds array = [
  'a'
  'b'
]
var dataContributorRoleId = '00000000-0000-0000-0000-000000000002'

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2021-01-15' existing = {
  name: resourceName
}

@batchSize(1)
resource repro 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = [ for servicePrincipalId in servicePrincipalIds: {
  name: 'repo/${servicePrincipalId}'
  properties: {
    roleDefinitionId: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.DocumentDB/databaseAccounts/${resourceName}/sqlRoleDefinitions/${dataContributorRoleId}'
    principalId: servicePrincipalId
    scope: databaseAccount.id
  }
}]
