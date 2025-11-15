// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(1)
@maxLength(63)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The resource subnet ID.')
param subnetId string

var containers = [
  {
    name: 'mycontainer'
    properties: {
      image: 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
      resources: {
        requests: {
          cpu: 1
          memoryInGB: 2
        }
      }
    }
  }
]

// An example Azure Container Instance with a network profile.
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2025-09-01' = {
  name: name
  location: location
  properties: {
    containers: containers
    osType: 'Linux'
    sku: 'Standard'
    restartPolicy: 'Always'
    ipAddress: {
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
      type: 'Private'
    }
    subnetIds: [
      {
        id: subnetId
      }
    ]
  }
}
