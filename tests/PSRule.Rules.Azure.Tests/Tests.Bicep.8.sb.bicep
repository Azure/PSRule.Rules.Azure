// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location
param iteration string

resource servicebus 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: 'servicebus'
  location: location
}

resource dianotics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: servicebus
  name: 'logs'
  properties: {
    #disable-next-line BCP037
    other: iteration
    logs: [
      {
        enabled: true
        categoryGroup: 'AllLogs'
      }
    ]
  }
}
