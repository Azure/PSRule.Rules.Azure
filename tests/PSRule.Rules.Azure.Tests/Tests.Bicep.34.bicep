// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param keyVaultName string = 'vault1'
param objectId string = newGuid()

var newAccessPolicies = [
  {
    tenantId: tenant().tenantId
    objectId: objectId
    permissions: {
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
      certificates: []
    }
  }
]

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

#disable-next-line BCP035
resource keyvault2 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${keyVaultName}-2'

  #disable-next-line BCP035
  properties: {}
}

var existingAccessPolicies = keyvault.properties.accessPolicies
var allPolicies = union(existingAccessPolicies, newAccessPolicies)

module addPolicies './Tests.Bicep.34.child.bicep' = {
  params: {
    accessPolicies: allPolicies
    keyVaultName: keyVaultName
  }
}
