// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the virtual network.')
param vnetName string = 'vnet-001'

@description('The location to deploy resources.')
param location string = resourceGroup().location

@description('')
param addressPrefix array = [
  '10.0.0.0/8'
]

@description('')
param subnets array = [
  {
    name: 'subnet1'
    addressPrefix: '10.1.0.32/28'
    securityRules: [
      {
        name: 'deny-rdp-inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '3389'
          ]
          access: 'Deny'
          priority: 200
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'deny-hop-outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '3389'
            '22'
          ]
          access: 'Deny'
          priority: 200
          direction: 'Outbound'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  {
    name: 'subnet2'
    addressPrefix: '10.1.0.64/28'
    securityRules: []
  }
]

var subscriptionDefaultTags = {
  'ffffffff-ffff-ffff-ffff-ffffffffffff': {
    role: 'Networking'
  }
  'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn': {
    role: 'Custom'
  }
  '00000000-0000-0000-0000-000000000000': {
    role: 'Networking'
  }
}
var rgLocation = {
  eastus: 'region-A'
  region: 'region-A'
  custom: 'Custom'
}
var gatewaySubnet = [
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: '${split(addressPrefix[0], '/')[0]}/27'
    }
  }
  {
    name: 'hsm'
    properties: {
      addressPrefix: '10.1.0.128/27'
      delegations: [
        {
          name: 'HSM'
          properties: {
            serviceName: 'Microsoft.HardwareSecurityModules/dedicatedHSMs'
          }
        }
      ]
    }
  }
  {
    name: 'RouteServerSubnet'
    properties: {
      addressPrefix: '10.1.0.196/27'
    }
  }
]
var definedSubnets = [
  for item in subnets: {
    name: item.name
    properties: {
      addressPrefix: item.addressPrefix
      networkSecurityGroup: {
        id: resourceId('Microsoft.Network/networkSecurityGroups', 'nsg-${item.name}')
      }
      routeTable: {
        id: resourceId('Microsoft.Network/routeTables/', 'route-${item.name}')
      }
    }
  }
]
var allSubnets = union(gatewaySubnet, definedSubnets)
var vnetAddressSpace = {
  addressPrefixes: addressPrefix
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: rgLocation[location]
  properties: {
    addressSpace: vnetAddressSpace
    subnets: allSubnets
  }
  tags: subscriptionDefaultTags[subscription().subscriptionId]
  dependsOn: [
    nsg
  ]
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-04-01' = [
  for item in subnets: if (true) {
    name: 'nsg-${item.name}'
    location: location
    properties: {
      securityRules: item.securityRules
    }
    dependsOn: []
  }
]

resource vnet_002_subnet_extra 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: 'vnet-002/subnet-extra'
  properties: {
    addressPrefix: '10.100.0.0/24'
  }
}

// Additional test cases for https://github.com/Azure/PSRule.Rules.Azure/issues/3497
// Based on work provided by @SangMinhTruong

resource vnet_empty 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-empty'
  location: location
  tags: {
    module: 'networking'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource vnet_separate 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-separate-subnet'
  location: location
  tags: {
    module: 'networking'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet_separate 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: vnet_separate
  name: 'snet-separate'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource vnet_embedded 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-embedded-subnet'
  location: location
  tags: {
    module: 'networking'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-embedded'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
