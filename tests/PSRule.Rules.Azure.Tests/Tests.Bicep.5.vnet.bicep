// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param addressPrefixes array
param firewallDeployment string
param subnets array

resource deployment 'Microsoft.Resources/deployments@2021-04-01' existing = {
  name: firewallDeployment
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-001'
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: {
      dnsServers: array(deployment.properties.outputs.azureFirewallPrivateIPAddress)
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: {
          id: subnet.networkSecurityGroupId
        }
      }
    }]
  }
}
