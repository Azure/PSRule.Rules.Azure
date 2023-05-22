// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Related to: https://github.com/Azure/PSRule.Rules.Azure/issues/2220

param location string = resourceGroup().location

var tasks = [
  {
    Value: 1
  }
  {
    Config: {
      Disable: true
    }
  }
]

var tasksWithDefaults = [for task in tasks: {
  Value: contains(task, 'Value') ? task.Value : 0
  Config: contains(task, 'Config') ? task.Config : {}
}]

var task = tasksWithDefaults[0]

resource taskDeployment 'Microsoft.Resources/deployments@2020-10-01' = {
  name: 'name'
  location: location
  properties: {
    mode: 'Incremental'
    parameters: {
      Enabled: (!contains(task.Config, 'Disable')) || (!task.Config.Disable)
    }
  }
}
