// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'vault-001'
}

module child './deployment-1.tests.bicep' = {
  name: 'child-deployment'
  params: {
    name: 'child'
    location: location
    adminUsername: vault.getSecret('adminUsername')
    adminPassword: vault.getSecret('adminPassword')
  }
}

module child1 './deployment-1.tests.bicep' = {
  name: 'child1-deployment'
  params: {
    name: 'child1'
    location: location
    adminUsername: vault.getSecret('adminUsername')
    adminPassword: vault.getSecret('adminPassword')
  }
}
