// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'subscription'

// Bicep documentation examples

// Configures Azure Defender for Container Registry.
resource defenderForContainerRegistry 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ContainerRegistry'
  properties: {
    pricingTier: 'Standard'
  }
}

// Configures Azure Defender for Containers.
resource defenderForContainers 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Containers'
  properties: {
    pricingTier: 'Standard'
  }
}
