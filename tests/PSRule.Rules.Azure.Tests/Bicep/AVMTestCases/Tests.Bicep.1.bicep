// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3153

param location string = resourceGroup().location
param privateEndpoints array = [
  {
    service: 'vault'
    subnetResourceId: 'subnetId'
  }
  {
    service: 'vault'
    subnetResourceId: 'subnetId'
    customNetworkInterfaceName: 'nic1'
  }
]
param enableTelemetry bool = false

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.2.1'
@description('Optional. The lock settings of the service.')
param lock lockType?
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'keyVault'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

module keyVault_privateEndpoints 'br/public:avm/res/network/private-endpoint:0.9.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-keyVault-PrivateEndpoint-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
              properties: {
                privateLinkServiceId: keyVault.id
                groupIds: [
                  privateEndpoint.?service ?? 'vault'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
              properties: {
                privateLinkServiceId: keyVault.id
                groupIds: [
                  privateEndpoint.?service ?? 'vault'
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: privateEndpoint.?enableTelemetry ?? enableTelemetry
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? tags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

output ids string[] = union(
  keyVault_privateEndpoints[0].outputs.networkInterfaceResourceIds,
  keyVault_privateEndpoints[1].outputs.networkInterfaceResourceIds
)

output id string[] = keyVault_privateEndpoints[1].outputs.networkInterfaceResourceIds
