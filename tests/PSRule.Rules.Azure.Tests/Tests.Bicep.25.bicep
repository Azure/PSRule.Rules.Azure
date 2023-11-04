// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

type FooConfig = {
  type: 'foo'
  value: int
}

type BarConfig = {
  type: 'bar'
  value: bool
}

@sys.discriminator('type')
type ServiceConfig = FooConfig | BarConfig | { type: 'baz', *: string }

param serviceConfig ServiceConfig = { type: 'bar', value: true }

resource value 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'example'
  #disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: serviceConfig.value
  }
}

output config object = serviceConfig
