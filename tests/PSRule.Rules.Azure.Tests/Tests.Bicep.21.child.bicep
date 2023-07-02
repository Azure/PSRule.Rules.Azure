// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('A list of subnets within the VNET.')
param subnetList array

// Check if the bastion subnet exists.
var subnetAzureBastion = filter(subnetList, item => item.name == 'AzureBastionSubnet')
var subnetAzureBastionSubnetaddressPrefix = !empty(subnetAzureBastion) ? subnetAzureBastion[0].properties.addressPrefix : ''

output rules array = !empty(subnetAzureBastion) ? [
  {
    name: 'allow-inbound-ssh-from-bastion'
    properties: {
      description: 'Allow SSH from bastion subnet.'
      direction: 'Inbound'
      priority: 100
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: subnetAzureBastionSubnetaddressPrefix
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'allow-inbound-rdp-from-bastion'
    properties: {
      description: 'Allow RDP from bastion subnet.'
      direction: 'Inbound'
      priority: 110
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: subnetAzureBastionSubnetaddressPrefix
      destinationAddressPrefix: '*'
    }
  }
] : []
