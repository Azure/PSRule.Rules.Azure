// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

var subnets = [
  {
    name: 'subnet1'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'subnet2'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'subnet3'
    addressPrefix: '10.0.2.0/24'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet1'
  properties: {
    subnets: [for item in subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
      }
    }]
  }
}

output subnets array = vnet.properties.subnets
