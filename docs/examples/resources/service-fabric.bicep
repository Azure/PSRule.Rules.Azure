// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(4)
@maxLength(23)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

param endpointUri string
param tenantId string
param clusterApplication string
param clientApplication string
param adminUsername string

@description('Certificate thumbprint.')
param certificateThumbprint string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' existing = {
  name: 'storage1'
}

// An example Service Fabric cluster.
resource cluster 'Microsoft.ServiceFabric/clusters@2023-11-01-preview' = {
  name: name
  location: location
  properties: {
    azureActiveDirectory: {
      clientApplication: clientApplication
      clusterApplication: clusterApplication
      tenantId: tenantId
    }
    certificate: {
      thumbprint: certificateThumbprint
      x509StoreName: 'My'
    }
    diagnosticsStorageAccountConfig: {
      blobEndpoint: storageAccount.properties.primaryEndpoints.blob
      protectedAccountKeyName: 'StorageAccountKey1'
      queueEndpoint: storageAccount.properties.primaryEndpoints.queue
      storageAccountName: storageAccount.name
      tableEndpoint: storageAccount.properties.primaryEndpoints.table
    }
    fabricSettings: [
      {
        parameters: [
          {
            name: 'ClusterProtectionLevel'
            value: 'EncryptAndSign'
          }
        ]
        name: 'Security'
      }
    ]
    managementEndpoint: endpointUri
    nodeTypes: []
    reliabilityLevel: 'Silver'
    upgradeMode: 'Automatic'
    vmImage: 'Windows'
  }
}

// An example Service Fabric managed cluster.
resource managed 'Microsoft.ServiceFabric/managedClusters@2024-04-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    azureActiveDirectory: {
      clientApplication: clientApplication
      clusterApplication: clusterApplication
      tenantId: tenantId
    }
    dnsName: toLower(name)
    adminUserName: adminUsername
    clientConnectionPort: 19000
    httpGatewayConnectionPort: 19080
    clients: [
      {
        isAdmin: true
        thumbprint: certificateThumbprint
      }
    ]
    loadBalancingRules: [
      {
        frontendPort: 8080
        backendPort: 8080
        protocol: 'tcp'
        probeProtocol: 'https'
      }
    ]
  }
}
