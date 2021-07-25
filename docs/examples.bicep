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

// An example App Gateway v2 with WAF enabled
resource appGw 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: 'appGw-001'
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
}
