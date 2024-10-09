// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2917

param identityId string = ''

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(split(identityId, '/')[4])
  name: split(identityId, '/')[8]
}

resource identity2 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup('00000000-0000-0000-0000-000000000000', split(identityId, '/')[4])
  name: split(identityId, '/')[8]
}

resource identity3 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'id-03'
}

#disable-next-line no-unused-existing-resources
resource policy1 'Microsoft.Authorization/policyDefinitions@2024-05-01' existing = {
  scope: managementGroup('mg-01')
  name: split(identityId, '/')[8]
}

#disable-next-line no-unused-existing-resources
resource assignment1 'Microsoft.Authorization/roleAssignments@2022-04-01' existing = {
  scope: identity2
  name: split(identityId, '/')[8]
}

module child './Tests.Bicep.2.child.bicep' = if (!empty(identityId)) {
  params: {
    principalId: identity.properties.principalId
  }
}

module child2 './Tests.Bicep.2.child.bicep' = {
  name: 'child2'
  params: {
    principalId: identity3.properties.principalId
  }
}
