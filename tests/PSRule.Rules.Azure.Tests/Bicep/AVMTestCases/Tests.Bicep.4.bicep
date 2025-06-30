// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3446

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: 'vnet/subnet'
}

resource vault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: 'vault'
}

module pe 'br/public:avm/res/network/private-endpoint:0.11.0' = {
  params: {
    name: 'pe-test'
    subnetResourceId: subnet.id
    manualPrivateLinkServiceConnections: [
      {
        name: 'manual-connection'
        properties: {
          groupIds: []
          privateLinkServiceId: vault.id
        }
      }
    ]
  }
}
