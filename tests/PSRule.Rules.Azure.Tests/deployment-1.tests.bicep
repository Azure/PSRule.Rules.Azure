// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string

param location string = resourceGroup().location

@secure()
param adminUsername string

@secure()
param adminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: name
  location: location
  properties: {
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}
