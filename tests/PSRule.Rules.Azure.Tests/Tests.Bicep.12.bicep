// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' existing = {
  name: 'vault1/key1'
}

module moduleName 'Tests.Bicep.12.child.bicep' = {
  name: 'moduleName'
  params: {
    keyName: keyVaultKey.name
    keyVersion: last(split(keyVaultKey.properties.keyUriWithVersion, '/'))
  }
}
