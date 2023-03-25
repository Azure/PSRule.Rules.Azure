// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location
var names = [ 'ws1', 'ws2' ]

var phases = {
  phase1: {
    workspace: 'ws1'
  }
  phase2: {
    workspace: 'w2'
  }
}

module keyvault 'Tests.Bicep.17.kv.bicep' = {
  name: 'keyvault'
  params: {
    names: length(names) > 1 ? names : []
    location: location
    prefix: 'logs-'
    ids: workspace.outputs.ids
  }
}

module workspace 'Tests.Bicep.17.ws.bicep' = {
  scope: resourceGroup('rg-monitoring')
  name: 'workspace'
  params: {
    location: location
    phases: !empty(phases) ? phases : {}
  }
}
