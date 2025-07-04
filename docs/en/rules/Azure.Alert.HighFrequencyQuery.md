---
reviewed: 2025-07-04
severity: Important
pillar: Cost Optimization
category: CO:06 Usage and billing increments
resource: Azure Monitor Alerts
resourceType: Microsoft.Insights/scheduledQueryRules
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Alert.HighFrequencyQuery/
---

# Scheduled Query Alert is configured to use a high frequency query

## SYNOPSIS

High frequency scheduled queries are changed as a higher rate than low frequency queries.

## DESCRIPTION

Azure Monitor scheduled query rules are used to monitor logs by running queries against log data.
Scheduled query rules can be configured to run at different frequencies such as:

- Every 1 minute.
- Every 5 minutes.
- Every 10 minutes.
- Every 15 minutes.

In many cases, a lower frequency such as 5 or 10 minutes intervals is sufficient for monitoring logs.
Using a high frequency query, such as every 1 minute, can lead to increased costs and may not provide additional value.

For logs to be queryable, they must first be ingested into Azure Monitor,
however the average latency to ingest log data is between 20 seconds and 3 minutes.

This rule identifies scheduled query rules that are configured to run every 1 minute.

## RECOMMENDATION

Consider using a lower frequency for scheduled queries or use metric alerts to reduce costs for operational monitoring.

## EXAMPLES

### Configure with Bicep

To deploy scheduled query rules that pass this rule:

- Set the `properties.evaluationFrequency` property to a value greater than 1 minute, such as `PT5M` or `PT10M`.

For example:

```bicep
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
```

<!-- external:avm avm/res/insights/scheduled-query-rule evaluationFrequency -->

### Configure with Azure template

To deploy scheduled query rules that pass this rule:

- Set the `properties.evaluationFrequency` property to a value greater than 1 minute, such as `PT5M` or `PT10M`.

For example:

```json
{
  "type": "Microsoft.Insights/scheduledQueryRules",
  "apiVersion": "2023-12-01",
  "name": "Virtual Machine Health - High CPU Usage",
  "location": "[parameters('location')]",
  "properties": {
    "description": "Monitor virtual machines for high CPU usage over an extended period.",
    "severity": 2,
    "enabled": true,
    "autoMitigate": true,
    "scopes": [
      "[parameters('resourceId')]"
    ],
    "evaluationFrequency": "PT10M",
    "windowSize": "PT1H",
    "criteria": {
      "allOf": [
        {
          "query": "Perf | where ObjectName == \"Processor\" and CounterName == \"% Processor Time\"",
          "metricMeasureColumn": "AggregatedValue",
          "resourceIdColumn": "[variables('resourceIdColumn')]",
          "dimensions": [],
          "operator": "GreaterThan",
          "threshold": 90,
          "timeAggregation": "Average",
          "failingPeriods": {
            "numberOfEvaluationPeriods": 1,
            "minFailingPeriodsToAlert": 1
          }
        }
      ]
    },
    "checkWorkspaceAlertsStorageConfigured": false,
    "actions": {
      "actionGroups": [
        "[parameters('actionGroupId')]"
      ],
      "customProperties": {
        "key1": "value1",
        "key2": "value2"
      }
    }
  }
}
```

## LINKS

- [CO:06 Usage and billing increments](https://learn.microsoft.com/azure/well-architected/cost-optimization/align-usage-to-billing-increments)
- [Set up a log search alert](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-create-log-alert-rule)
- [Azure Monitor pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [Log data ingestion time in Azure Monitor](https://learn.microsoft.com/azure/azure-monitor/logs/data-ingestion-time)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/scheduledqueryrules)
