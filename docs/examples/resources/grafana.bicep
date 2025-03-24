// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@sys.description('The name of the resource.')
param name string

@sys.description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example of a Grafana resource with a system-assigned identity and the Standard SKU.
resource grafana 'Microsoft.Dashboard/grafana@2024-10-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    grafanaMajorVersion: '11'
    zoneRedundancy: 'Enabled'
  }
}
