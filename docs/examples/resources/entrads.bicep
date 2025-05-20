// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The location of the secondary replica set.')
param secondaryLocation string

@description('The ID of the subnet for the primary replica set.')
param primarySubnetId string

@description('The ID of the subnet for the secondary replica set.')
param secondarySubnetId string

// Bicep documentation examples

// Configure a hardened Entra Domain Services instance.
resource ds 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: name
  location: location
  properties: {
    sku: 'Enterprise'
    ldapsSettings: {
      ldaps: 'Enabled'
    }
    domainSecuritySettings: {
      ntlmV1: 'Disabled'
      tlsV1: 'Disabled'
      kerberosRc4Encryption: 'Disabled'
    }
    replicaSets: [
      {
        subnetId: primarySubnetId
        location: location
      }
      {
        subnetId: secondarySubnetId
        location: secondaryLocation
      }
    ]
  }
}
