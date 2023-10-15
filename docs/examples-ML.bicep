// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the ML - Compute Instance.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The VM SKU to be deployed.')
param vmSize string = 'STANDARD_D2_V2'

@description('The Idle time before shutdown, as a string in ISO 8601 format.')
// this must be a string in ISO 8601 format
param idleTimeBeforeShutdown string = 'PT15M'

resource managedRg 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope: subscription()
  name: 'psrule'
}

resource mlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-04-01' existing = {
  name: 'example-ws'
}

resource aml_compute_instance 'Microsoft.MachineLearningServices/workspaces/computes@2023-04-01' = {
  name: '${mlWorkspace.name}/${name}'
  location: location
  properties: {
    managedResourceGroupId: managedRg.id
    computeType: 'ComputeInstance'
    properties: {
      vmSize: vmSize
      idleTimeBeforeShutdown: idleTimeBeforeShutdown
    }
  }
}
