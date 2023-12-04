// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@secure()
param secret string

resource vault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: 'vault1'
}

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: vault
  name: 'secret2'
  properties: {
    value: secret
  }
}

// Secret from key vault reference assigned to output
output secretFromParameter string = secret
