// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2424

#disable-next-line no-hardcoded-location
var location = 'eastus'

module serviceBus './Tests.Bicep.29.child.bicep' = {
  name: 'my-test-service-bus'
  params: {
    Location: location
    ServiceBusSkuName: 'Standard'
  }
}

var logicAppParams = {
  '$connections': {
    value: {
      serviceBusSender: {
        connectionId: serviceBus.outputs.SendConnection.Id
        connectionName: serviceBus.outputs.SendConnection.Name
        id: subscriptionResourceId(serviceBus.outputs.SendConnection.Api.Type, location, serviceBus.outputs.SendConnection.Api.Name)
      }
      serviceBusListener: {
        connectionId: serviceBus.outputs.ListenConnection.Id
        connectionName: serviceBus.outputs.ListenConnection.Name
        id: subscriptionResourceId(serviceBus.outputs.ListenConnection.Api.Type, location, serviceBus.outputs.ListenConnection.Api.Name)
      }
    }
  }
}

resource workflow 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'a-test-logic-app'
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      // Actual definition omitted
    }
    parameters: logicAppParams
  }
}
