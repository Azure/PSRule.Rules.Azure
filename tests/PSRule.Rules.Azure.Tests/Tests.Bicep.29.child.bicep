// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2424

param Location string = resourceGroup().location
param ServiceBusSkuName string = 'Standard'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'myServiceBus'
  location: Location
  sku: {
    name: ServiceBusSkuName
    tier: ServiceBusSkuName
  }
  properties: {
    minimumTlsVersion: '1.2'
  }

  resource sendAuthRule 'AuthorizationRules' = {
    name: 'SendAccess'
    properties: {
      rights: [
        'Send'
      ]
    }
  }

  resource listenAuthRule 'AuthorizationRules' = {
    name: 'ListenAccess'
    properties: {
      rights: [
        'Listen'
      ]
    }
  }

  // Queues and Topics omitted

}

resource sendApiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'sender-connection'
  location: Location
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', Location, 'servicebus')
    }
    displayName: 'sender-connection'
    parameterValues: {
      connectionString: listKeys(serviceBus::sendAuthRule.name, serviceBus.apiVersion).primaryConnectionString
    }
  }
}

resource listenApiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'listener-connection'
  location: Location
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', Location, 'servicebus')
    }
    displayName: 'listener-connection'
    parameterValues: {
      connectionString: listKeys(serviceBus::listenAuthRule.name, serviceBus.apiVersion).primaryConnectionString
    }
  }
}

output SendConnection object = {
  Name: sendApiConnection.name
  Id: sendApiConnection.id
  Api: {
    Name: sendApiConnection.properties.api.name
    Type: sendApiConnection.properties.api.type
  }
}

output ListenConnection object = {
  Name: listenApiConnection.name
  Id: listenApiConnection.id
  Api: {
    Name: listenApiConnection.properties.api.name
    Type: listenApiConnection.properties.api.type
  }
}
