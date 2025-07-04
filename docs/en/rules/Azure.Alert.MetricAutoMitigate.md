---
reviewed: 2025-07-04
severity: Important
pillar: Cost Optimization
category: CO:13 Personnel time
resource: Azure Monitor Alerts
resourceType: Microsoft.Insights/metricAlerts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Alert.MetricAutoMitigate/
---

# Metric Alert requires manual mitigation

## SYNOPSIS

Alerts that require manual intervention for mitigation can lead to increased personnel time and effort.

## DESCRIPTION

Azure Monitor metric alert rules can be configured to be stateful, this helps optimize personnel time by:

- Monitoring the state of an alert condition, and firing an alert when the condition is met.
- Continuing to track the alert condition and automatically resolving the alert when the condition is no longer met.

When this option is not enabled, personnel must manually resolve the alert.
Such alerts can increase the workload on personnel, as they need to respond to and resolve these alerts manually.

Automatically mitigating alerts helps reduce the time spent on alert management and reduces alert fatigue.

Additionally, alert notifications can optionally be configured as needed based on the nature and severity of the alert.

## RECOMMENDATION

Consider enabling stateful alerts to reduce alert fatigue and focus personnel time on issues that require attention.

## EXAMPLES

### Configure with Bicep

To deploy alert metric rules that pass this rule:

- Set the `properties.autoMitigate` property to `true`.

For example:

```bicep
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
```

<!-- external:avm avm/res/insights/metric-alert autoMitigate -->

### Configure with Azure template

To deploy alert metric rules that pass this rule:

- Set the `properties.autoMitigate` property to `true`.

For example:

```json
{
  "type": "Microsoft.Insights/metricAlerts",
  "apiVersion": "2018-03-01",
  "name": "Container App Health - Replica Restarts",
  "location": "global",
  "properties": {
    "description": "Monitor replicas for restarts above then the threshold.",
    "severity": 2,
    "enabled": true,
    "autoMitigate": true,
    "scopes": [
      "[parameters('resourceId')]"
    ],
    "evaluationFrequency": "PT1M",
    "windowSize": "PT30M",
    "criteria": {
      "allOf": [
        {
          "threshold": 10,
          "name": "RestartCount",
          "metricNamespace": "microsoft.app/containerapps",
          "metricName": "RestartCount",
          "dimensions": [
            {
              "name": "revisionName",
              "operator": "Include",
              "values": [
                "*"
              ]
            }
          ],
          "operator": "GreaterThan",
          "timeAggregation": "Maximum",
          "criterionType": "StaticThresholdCriterion"
        }
      ],
      "odata.type": "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria"
    },
    "targetResourceType": "Microsoft.App/containerApps",
    "targetResourceRegion": "[parameters('location')]",
    "actions": [
      {
        "actionGroupId": "[parameters('actionGroupId')]"
      }
    ]
  }
}
```

## LINKS

- [CO:13 Personnel time](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-personnel-time)
- [Set up a metric alert](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-create-metric-alert-rule)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/metricalerts)
