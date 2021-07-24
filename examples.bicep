// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

// An example NSG with a single rule to deny outbound management traffic
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'nsg-001'
  properties: {
    securityRules: [
      {
        name: 'deny-hop-outbound'
        properties: {
          priority: 200
          access: 'Deny'
          protocol: 'Tcp'
          direction: 'Outbound'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '3389'
            '22'
          ]
        }
      }
    ]
  }
}
