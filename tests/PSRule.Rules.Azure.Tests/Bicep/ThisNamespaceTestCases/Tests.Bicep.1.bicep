// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3884
param keepExistingTags bool = true
param tags object = {
  environment: 'test'
}
param extraSubnets array = [
  {
    name: 'functionApp'
    addressCount: '32'
  }
]

func getSubnetExistingAddressPrefixes(subnets array?, subnetName string) string[]? =>
  filter(subnets ?? [], subnet => subnet.name == subnetName)[?0].?properties.addressPrefixes

resource storage 'Microsoft.Storage/storageAccounts@2025-06-01' = [for i in range(0, 2): {
  name: 'thisnamespacetest${i}'
  location: 'eastus'
  tags: keepExistingTags ? union(this.existingResource().?tags ?? {}, tags) : tags
  sku: {
    name: this.existingResource().?sku.name ?? 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: this.exists() ? this.existingResource()!.properties.accessTier : 'Cold'
  }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: 'vnet-test'
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: this.existingResource().?properties.addressSpace.addressPrefixes
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '256'
          pool: {
            id: resourceId('Microsoft.Network/networkManagers/ipamPools', 'vnm-test', 'pool-test')
          }
        }
      ]
    }
    subnets: concat(
      [
        {
          name: 'App'
          properties: {
            addressPrefixes: getSubnetExistingAddressPrefixes(this.existingResource().?properties.subnets, 'App')
            ipamPoolPrefixAllocations: [
              {
                numberOfIpAddresses: '128'
                pool: {
                  id: resourceId('Microsoft.Network/networkManagers/ipamPools', 'vnm-test', 'pool-test')
                }
              }
            ]
          }
        }
      ],
      map(extraSubnets, subnet => {
        name: subnet.name
        properties: {
          addressPrefixes: getSubnetExistingAddressPrefixes(this.existingResource().?properties.subnets, subnet.name)
          ipamPoolPrefixAllocations: [
            {
              numberOfIpAddresses: subnet.addressCount
              pool: {
                id: resourceId('Microsoft.Network/networkManagers/ipamPools', 'vnm-test', 'pool-test')
              }
            }
          ]
        }
      })
    )
  }
}
