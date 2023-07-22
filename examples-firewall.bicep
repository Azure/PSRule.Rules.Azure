// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the resource.')
param name string = 'firewall'

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource firewall_classic 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: '${name}_classic'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
    }
    threatIntelMode: 'Deny'
  }
}

resource firewall_policy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: '${name}_policy'
  properties: {
    threatIntelMode: 'Deny'
  }
}

// An example Azure Firewall Premium with a linked firewall policy.
resource firewall 'Microsoft.Network/azureFirewalls@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    firewallPolicy: {
      id: firewall_policy.id
    }
  }
}

resource hub 'Microsoft.Network/virtualHubs@2021-05-01' = {
  name: '${name}_hub'
  location: location
}

resource firewall_with_hub 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: '${name}_with_hub'
  location: location
  properties: {
    sku: {
      name: 'AZFW_Hub'
    }
    firewallPolicy: {
      id: firewall_policy.id
    }
    virtualHub: {
      id: hub.id
    }
  }
}
