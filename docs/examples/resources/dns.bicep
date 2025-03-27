// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the resource.')
param name string

// An example Public DNS zone.
resource zone 'Microsoft.Network/dnsZones@2023-07-01-preview' = {
  name: name
  location: 'Global'
  properties: {
    zoneType: 'Public'
  }
}

// An example DNSSEC configuration for a public DNS zone.
resource dnssec 'Microsoft.Network/dnsZones/dnssecConfigs@2023-07-01-preview' = {
  parent: zone
  name: 'default'
}
