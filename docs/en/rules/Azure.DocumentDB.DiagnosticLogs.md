---
reviewed: 2026-11-23
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.DiagnosticLogs/
---

# Enable Azure DocumentDB request diagnostic logs

## SYNOPSIS

Azure DocumentDB clusters on supported compute tiers should enable request diagnostic logs.

## DESCRIPTION

Request logs help operators investigate failures, latency, and unusual database activity.
Azure Monitor gathers platform metrics and activity logs automatically, but resource logs require diagnostic settings.
Enable the `vCoreMongoRequests` category or the `allLogs` category group.

Diagnostic logs are not available on M30 and lower compute tiers or free-tier clusters.
This rule evaluates clusters with an explicitly configured numeric M-series tier greater than M30.

## RECOMMENDATION

Consider enabling request diagnostic logs and routing them to an appropriate monitoring destination.

## EXAMPLES

### Configure with Azure template

Associate the following extension resource with an M40 or higher cluster.
The workspace must already exist and be accessible to the deployment.

```json
{
  "type": "Microsoft.Insights/diagnosticSettings",
  "apiVersion": "2021-05-01-preview",
  "name": "documentdb-logs",
  "scope": "[format('Microsoft.DocumentDB/mongoClusters/{0}', parameters('clusterName'))]",
  "properties": {
    "workspaceId": "[parameters('workspaceId')]",
    "logs": [
      {
        "category": "vCoreMongoRequests",
        "enabled": true
      }
    ]
  }
}
```

### Configure with Bicep

```bicep
param clusterName string
param workspaceId string

resource cluster 'Microsoft.DocumentDB/mongoClusters@2026-06-01' existing = {
  name: clusterName
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'documentdb-logs'
  scope: cluster
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'vCoreMongoRequests'
        enabled: true
      }
    ]
  }
}
```

## NOTES

Supply diagnostic settings with the cluster resource so the rule can evaluate the association.
Disabled categories, unrelated categories, and metrics-only settings do not satisfy this rule.
The rule does not assume that the `audit` category group contains request logs.
It checks logging configuration, not destination availability, retention, or actual log ingestion.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [Monitor diagnostics logs](https://learn.microsoft.com/azure/documentdb/how-to-monitor-diagnostics-logs)
- [Supported resource logs](https://learn.microsoft.com/azure/azure-monitor/reference/supported-logs/microsoft-documentdb-mongoclusters-logs)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
