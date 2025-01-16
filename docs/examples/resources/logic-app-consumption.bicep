// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example Logic App with IP restrictions.
resource app 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  properties: {
    definition: '<workflow-definition>'
    parameters: {}
    accessControl: {
      contents: {
        allowedCallerIpAddresses: [
          {
            addressRange: '192.168.12.0/23'
          }
          {
            addressRange: '2001:0db8::/64'
          }
        ]
      }
    }
  }
}
