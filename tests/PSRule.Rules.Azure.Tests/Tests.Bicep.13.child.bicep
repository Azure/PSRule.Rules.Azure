// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

var base = '10.0.0.0/8'

var subnets = [
  {
    name: 'subnet1'
    addressPrefix: cidrSubnet(base, 24, 0)
  }
  {
    name: 'subnet2'
    addressPrefix: cidrSubnet(base, 24, 1)
  }
  {
    name: 'subnet3'
    addressPrefix: cidrSubnet(base, 24, 2)
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
