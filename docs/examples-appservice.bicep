// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the App Services Plan.')
param planName string


@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example App Services Plan
resource appPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: planName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 2
  }
}
