// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2054

param prefix string = 'super'
param deployed bool = true

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'vault1'
}

module withSecret 'Tests.Bicep.1.child.bicep' = {
  name: 'withSecret'
  params: {
    name: '1'
    secret: deployed ? vault.getSecret('${prefix}secret1') : 'placeholder'
  }
}

module withPlaceholder 'Tests.Bicep.1.child.bicep' = {
  name: 'withPlaceholder'
  params: {
    name: '2'
    secret: !deployed ? vault.getSecret('${prefix}secret1') : 'placeholder'
  }
}
