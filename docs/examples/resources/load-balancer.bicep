// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(1)
@maxLength(80)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The resource ID of the virtual network subnet.')
param subnetId string

@description('The resource ID of the public IP address.')
param pipId string

// An example internal load balancer with availability zones configured.
resource internal_lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
        zones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
  }
}

// An example load balancer with serving HTTPS from a backend pool.
resource https_lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontend1'
        properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
        zones: [
          '2'
          '3'
          '1'
        ]
      }
    ]
    backendAddressPools: [
      {
        name: 'backend1'
      }
    ]
    probes: [
      {
        name: 'https'
        properties: {
          protocol: 'HTTPS'
          port: 443
          requestPath: '/health'
          intervalInSeconds: 5
          numberOfProbes: 1
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, 'frontend1')
          }
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'TCP'
          loadDistribution: 'Default'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', name, 'https')
          }
          disableOutboundSnat: true
          enableTcpReset: false
          backendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, 'backend1')
            }
          ]
        }
      }
    ]
    inboundNatRules: []
    outboundRules: []
  }
}

// An example public load balancer.
resource public_lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig'
        properties: {
          publicIPAddress: {
            id: pipId
          }
        }
      }
    ]
  }
}
