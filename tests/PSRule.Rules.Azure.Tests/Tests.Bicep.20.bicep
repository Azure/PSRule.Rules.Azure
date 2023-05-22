// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Related to: https://github.com/Azure/PSRule.Rules.Azure/issues/2221

param location string = resourceGroup().location

var array1 = []
var array2 = [for i in array1: union(
  {
    Value: ''
  },
  i)]

var array3 = [for i in array2: {
  name: 'task'
  parameters: i
}]

resource taskDeployment 'Microsoft.Resources/deployments@2020-10-01' = {
  name: 'name'
  location: location
  properties: {
    mode: 'Incremental'
    parameters: {
      downloadSnapshots: array3
    }
  }
}
