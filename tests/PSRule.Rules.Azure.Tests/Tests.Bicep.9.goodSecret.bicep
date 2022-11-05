// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@secure()
param secret string

resource goodSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'keyvault/good'
  properties: {
    value: secret
  }
}
