// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

targetScope = 'subscription'

@minLength(1)
@maxLength(90)
@description('The name of the resource group.')
param name string

@description('The location resource group will be deployed.')
param location string

// An example resource group.
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: {
    environment: 'production'
    costCode: '349921'
  }
}
