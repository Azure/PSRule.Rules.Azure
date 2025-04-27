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

@description('Tags to assign to the resource group.')
param tags requiredTags

@description('A custom type defining the required tags on a resource groups.')
type requiredTags = {
  Env: string
  CostCode: string
}

// An example resource group.
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: tags
}
