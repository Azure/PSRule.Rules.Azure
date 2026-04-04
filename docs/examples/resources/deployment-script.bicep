// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '11.0'
    retentionInterval: 'P1D'
    primaryScriptUri: 'https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/8dc395b739a8be00571d039c0af9df88d85c1e2a/scripts/pipeline-deps.ps1'
  }
}
