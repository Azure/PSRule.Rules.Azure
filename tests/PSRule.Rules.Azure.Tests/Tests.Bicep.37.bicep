// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2829

param location string = resourceGroup().location

resource storageRef 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'storage'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

module kv 'br/public:avm/res/key-vault/vault:0.5.1' = {
  name: 'test'
  params: {
    name: 'test'
    sku: 'standard'
    secrets: {
      secureList: [
        {
          name: storageRef.name
          value: storageRef.listKeys().keys[0].value
          attributesExp: 1702648632
          attributesNbf: 10000
        }
      ]
    }
  }
}
