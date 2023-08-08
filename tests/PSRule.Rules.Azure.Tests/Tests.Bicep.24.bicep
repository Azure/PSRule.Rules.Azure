// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'subscription'

param enableSecurityCenterFor array = [
  'VirtualMachines'
  'AppServices'
  'SqlServers'
  'SqlServerVirtualMachines'
  'OpenSourceRelationalDatabases'
  'StorageAccounts'
  'Containers'
  'KeyVaults'
  'Arm'
  'DNS'
]

var disableSecurityCenterFor = [
  'VirtualMachines'
  'AppServices'
  'SqlServers'
  'SqlServerVirtualMachines'
  'OpenSourceRelationalDatabases'
  'StorageAccounts'
  'Containers'
  'KeyVaults'
  'Arm'
  'DNS'
]

resource securityCenterPricing 'Microsoft.Security/pricings@2018-06-01' = [for name in disableSecurityCenterFor: {
  name: name
  properties: {
    pricingTier: contains(enableSecurityCenterFor, name) ? 'Standard' : 'Free'
  }
}]
