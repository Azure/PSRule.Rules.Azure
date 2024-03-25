param location string = resourceGroup().location

module topic 'br/public:avm/res/event-grid/topic:0.1.4' = {
  name: '${uniqueString(deployment().name, location)}-test-egtwaf'
  params: {
    // Required parameters
    name: 'egtwaf001'
    // Non-required parameters
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    eventSubscriptions: [
      {
        destination: {
          endpointType: 'StorageQueue'
          properties: {
            queueMessageTimeToLiveInSeconds: 86400
            queueName: '<queueName>'
            resourceId: '<resourceId>'
          }
        }
        eventDeliverySchema: 'CloudEventSchemaV1_0'
        expirationTimeUtc: '2099-01-01T11:00:21.715Z'
        filter: {
          enableAdvancedFilteringOnArrays: true
          isSubjectCaseSensitive: false
        }
        name: 'egtwaf001'
        retryPolicy: {
          eventTimeToLive: '120'
          maxDeliveryAttempts: 10
        }
      }
    ]
    inboundIpRules: []
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        service: 'topic'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
