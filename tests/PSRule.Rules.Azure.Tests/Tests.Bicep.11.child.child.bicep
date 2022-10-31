// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param value5 array

resource item 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: value5[0].staticPublicIP
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  location: resourceGroup().location
  properties: {}
  tags: {
    value6: value5[0].value6
    value7: value5[0].value7
    ip: value5[0].staticPublicIP
  }
}
