// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param enableOption bool = false

var optionsPrep = {
  enable: enableOption ? 'notnull' : null
}

var options = {
  prop1: 'one'
  enable: optionsPrep.enable == null ? null : 'doit!'
}

resource taskDeployment 'Microsoft.Resources/deployments@2020-10-01' = {
  name: 'name'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: [
        {
          apiVersion: '2019-12-01'
          type: 'Microsoft.ManagedIdentity/userAssignedIdentities'
          name: 'example'
          properties: {
            taskOptions: options
          }
        }
      ]
    }
  }
}
