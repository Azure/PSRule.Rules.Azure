// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param keyVaultName string
param accessPolicies array

// Policies to add.
resource additionalPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: accessPolicies
  }
}
