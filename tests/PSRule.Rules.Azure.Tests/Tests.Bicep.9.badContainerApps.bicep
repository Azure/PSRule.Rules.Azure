// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Disable linter rule
#disable-next-line secure-secrets-in-params
param notSecret string

resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'badContainerApp'
  location: resourceGroup().location
  properties: {
    configuration: {
      secrets: [
        {
          name: 'badSecret'
          value: notSecret
        }
      ]
    }
  }
}
