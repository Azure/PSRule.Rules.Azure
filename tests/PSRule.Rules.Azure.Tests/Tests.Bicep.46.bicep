// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3972

param identityResourceGroup string = 'rg-identity'
param identityName string = 'id-issue-3972'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
  scope: resourceGroup(identityResourceGroup)
}

module child './Tests.Bicep.46.child.bicep' = {
  name: 'child'
  params: {
    grants: [
      {
        name: 'vault'
        principalId: identity.properties.principalId
      }
    ]
  }
}
