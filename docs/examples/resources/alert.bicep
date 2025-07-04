// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@sys.description('The location resources will be deployed.')
param location string = resourceGroup().location

@sys.description('The ID of the container app to monitor for replica restarts.')
param resourceId string

param actionGroupId string

var resourceIdColumn = ''

// An example metric alert rule that configures an alert for container apps.
resource alertHealthReplicaRestarts 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Container App Health - Replica Restarts'
  location: 'global'
  properties: {
    description: 'Monitor replicas for restarts above then the threshold.'
    severity: 2
    enabled: true
    autoMitigate: true
    scopes: [
      resourceId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT30M'
    criteria: {
      allOf: [
        {
          threshold: 10
          name: 'RestartCount'
          metricNamespace: 'microsoft.app/containerapps'
          metricName: 'RestartCount'
          dimensions: [
            {
              name: 'revisionName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Maximum'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }

    targetResourceType: 'Microsoft.App/containerApps'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

// An example scheduled query rule that configures an alert for high CPU usage on virtual machines.
resource alertHealthCPUUsage 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: 'Virtual Machine Health - High CPU Usage'
  location: location
  properties: {
    description: 'Monitor virtual machines for high CPU usage over an extended period.'
    severity: 2
    enabled: true
    autoMitigate: true
    scopes: [
      resourceId
    ]
    evaluationFrequency: 'PT10M'
    windowSize: 'PT1H'
    criteria: {
      allOf: [
        {
          query: 'Perf | where ObjectName == "Processor" and CounterName == "% Processor Time"'
          metricMeasureColumn: 'AggregatedValue'
          resourceIdColumn: resourceIdColumn
          dimensions: []
          operator: 'GreaterThan'
          threshold: 90
          timeAggregation: 'Average'
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    checkWorkspaceAlertsStorageConfigured: false
    actions: {
      actionGroups: [
        actionGroupId
      ]
      customProperties: {
        key1: 'value1'
        key2: 'value2'
      }
    }
  }
}
