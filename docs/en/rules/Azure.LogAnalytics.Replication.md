---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Log Analytics
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LogAnalytics.Replication/
---

# Replicate workspaces across regions

## SYNOPSIS

Log Analytics workspaces should have workspace replication enabled to improve service availability.

## DESCRIPTION

In the event of a service disruption, access to monitoring data and collection of new data in a workspace may be temporarily impacted.

Log Analytics workspaces support replication of monitoring data to a workspace to a secondary region.
When relication is enabled, new monitoring data is replicated to the secondary region in addition to the primary region.
Failover to the workspace in the secondary region can be triggered manually.

Some limitations apply:

- Failover occurs by updating DNS records to point to the secondary region.
  As a result, failover won't occur immediately and clients with open connections won't update until a new connection is established.
- Failover is a customer initiated action.
  Failover to the secondard region does not occur automatically.
- Data collection rules need to be updated to point to the system data collection endpoint for ingested data to be replicated.
- See documentation references below for additional limitations and important information.

## RECOMMENDATION

Consider replicating Log Analytics workspaces across regions to improve access to monitoring data in the event of a regional service disruption.

## EXAMPLES

### Configure with Azure template

To deploy Log Analytics workspaces that pass this rule:

- Set the `properties.replication.enabled` property to `true`.
- Set the `properties.replication.location` property to a supported region in the same region group as the workspace primary region.

For example:

```json
{
  "type": "Microsoft.OperationalInsights/workspaces",
  "apiVersion": "2023-01-01-preview",
  "name": "[parameters('name')]",
  "location": "westeurope",
  "properties": {
    "replication": {
      "enabled": true,
      "location": "northeurope"
    },
    "publicNetworkAccessForIngestion": "Enabled",
    "publicNetworkAccessForQuery": "Enabled",
    "retentionInDays": 30,
    "sku": {
      "name": "PERGB2018"
    }
  }
}
```

### Configure with Bicep

To deploy Log Analytics workspaces that pass this rule:

- Set the `properties.replication.enabled` property to `true`.
- Set the `properties.replication.location` property to a supported region in the same region group as the workspace primary region.

For example:

```bicep
resource workspace 'Microsoft.OperationalInsights/workspaces@2023-01-01-preview' = {
  name: name
  location: 'westeurope'
  properties: {
    replication: {
      enabled: true
      location: 'northeurope'
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    sku: {
      name: 'PERGB2018'
    }
  }
}
```

## NOTES

This feature for Log Analytics workspaces is currently in preview.

Replication of Log Analytics workspaces linked to a dedicated cluster is currently not supported.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Replicate workspace across regions](https://learn.microsoft.com/azure/azure-monitor/logs/workspace-replication)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces)
