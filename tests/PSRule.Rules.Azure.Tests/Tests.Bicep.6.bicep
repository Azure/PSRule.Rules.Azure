// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location


resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'script-001'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.1'
    retentionInterval: 'P1D'
    scriptContent: 'Write-Host'
    arguments: '(${loadTextContent('Tests.Bicep.6.content.json')} | ConvertTo-Json)'
  }
}
