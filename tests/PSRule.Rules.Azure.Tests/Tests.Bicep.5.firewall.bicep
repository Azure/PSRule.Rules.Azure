// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: 'firewall-001'
}

output azureFirewallPrivateIPAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
