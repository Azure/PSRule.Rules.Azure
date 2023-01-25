// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Disable linter rule
#disable-next-line secure-secrets-in-params
param notSecret string

resource badSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'keyvault/bad'
  properties: {
    value: notSecret
  }
}
