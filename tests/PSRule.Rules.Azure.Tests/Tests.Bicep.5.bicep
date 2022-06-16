// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

var subnets = [
  {
    subnetName: 'subnet-001'
    addressPrefix: '10.0.1.0/24'
  }
]

module firewall 'Tests.Bicep.5.firewall.bicep' = {
  name: 'fw_deploy'
}

module vnet 'Tests.Bicep.5.vnet.bicep' = {
  name: 'vnet_deploy'
  params: {
    addressPrefixes: [
      '10.0.0.0/8'
    ]
    firewallDeployment: firewall.name
    subnets: [for (subnet, index) in subnets: {
      name: subnet.subnetName
      addressPrefix: subnet.addressPrefix
      networkSecurityGroupId: nsg[index].outputs.networkSecurityGroupResourceId
    }]
  }
}

module nsg 'Tests.Bicep.5.nsg.bicep' = [for subnet in subnets: {
  name: 'nsg_deploy_${subnet.subnetName}'
  params: {
    name: 'nsg-${subnet.subnetName}'
  }
}]

resource route 'Microsoft.Network/routeTables@2021-08-01' = [for (item, index) in subnets: {
  name: 'route-${item.subnetName}'
  properties: {
    routes: [
      {
        name: 'route-${vnet.outputs.snet[index].name}'
        properties: {
          nextHopType: 'VirtualNetworkGateway'
          addressPrefix: vnet.outputs.snet[index].addressPrefix
          nextHopIpAddress: firewall.outputs.azureFirewallPrivateIPAddress
        }
      }
    ]
  }
}]
