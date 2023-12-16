// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2593

var task = {
  name: 'task1'
  parameters: {
    B: 5
  }
}

var tasks = [
  {
    name: task.name
    parameters: {
      debug: 'A\'${string(task.parameters)}\''
      debugLength: length('A\'${string(task.parameters)}\'')
    }
  }
]

#disable-next-line BCP081 no-deployments-resources
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
          name: 'test'
          properties: {
            tasks: tasks
          }
        }
      ]
    }
  }
}

output outTask object = task
output outTasks array = tasks
