// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string

@secure()
param secret string

resource secretToSet 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'vault1/toSet${name}'
  properties: {
    value: secret
  }
}
