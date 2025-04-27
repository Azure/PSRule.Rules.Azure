// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

targetScope = 'tenant'

@minLength(3)
@maxLength(24)
@description('The name of the resource.')
param name string

@description('Tags to assign to the subscription alias.')
param tags requiredTags

param billingScope string

@description('A custom type defining the required tags on a subscription.')
type requiredTags = {
  Env: string
  CostCode: string
}

// An example subscription alias.
resource subscription 'Microsoft.Subscription/aliases@2024-08-01-preview' = {
  name: name
  properties: {
    displayName: name
    billingScope: billingScope
    additionalProperties: {
      tags: tags
    }
  }
}
