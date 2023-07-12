// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'
metadata name = 'Front Door profile'
metadata description = 'Deploys and configures an Azure Front Door profile.'
metadata summary = 'Create or update an Azure Front Door.'

// ----------
// PARAMETERS
// ----------

@sys.description('The name of the Front Door.')
param name string = deployment().name

@metadata({
  strongType: 'Microsoft.ManagedIdentity/userAssignedIdentities'
})
@sys.description('A User-Assigned Managed Identity for the profile. This identity is used to access Key Vault.')
param identityId string = ''

@metadata({
  strongType: 'Microsoft.ManagedIdentity/userAssignedIdentities'
})
@sys.description('A User-Assigned Managed Identity for the profile. This identity is used to access Key Vault.')
param identityId2 string = '/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity-001'

@sys.description('Configures the send and receive timeout on forwarding request to the origin.')
param originResponseTimeoutSeconds int = 60

@sys.description('Create or update a Front Door.')
resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: name
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  identity: !empty(identityId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  } : null
  properties: {
    originResponseTimeoutSeconds: originResponseTimeoutSeconds
  }
}

@sys.description('Create or update a Front Door.')
resource profile2 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: '${name}2'
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId2}': {}
    }
  }
  properties: {
    originResponseTimeoutSeconds: originResponseTimeoutSeconds
  }
}

output identity object = profile2.identity.userAssignedIdentities[identityId2]
