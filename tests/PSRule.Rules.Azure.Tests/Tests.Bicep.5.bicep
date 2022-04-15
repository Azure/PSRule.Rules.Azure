// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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
  }
}
