// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Existing resources for reference
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: 'vnet001'
}

module bastionRules 'Tests.Bicep.21.child.bicep' = {
  name: '${deployment().name}-bastion'
  params: {
    subnetList: vnet.properties.subnets
  }
}
