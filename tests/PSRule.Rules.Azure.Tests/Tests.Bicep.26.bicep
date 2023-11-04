// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#disable-next-line no-unused-params
param notUsedTypedParam {
  Name: string
}[] = []

resource value 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'example'
  #disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    #disable-next-line BCP037
    fakeOptions: fakeOptions
  }
}

module modOne './Tests.Bicep.26.child1.bicep' = {
  name: 'one'
  params: {}
}

module modTwo './Tests.Bicep.26.child2.bicep' = {
  name: 'two'
  params: {
    input: modOne.outputs.result
  }
}

var fakeOptions = concat(
  modTwo.outputs.result
)

#disable-next-line BCP053
output result array = value.properties.fakeOptions
