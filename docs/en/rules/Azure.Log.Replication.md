---
reviewed: 2025-05-25
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Azure Monitor Logs
resourceType: Microsoft.OperationalInsights/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Log.Replication/
---

# Logs workspace is not replicated across regions

## SYNOPSIS

Log Analytics workspaces should have workspace replication enabled to improve service availability.

## DESCRIPTION

In the event of a service disruption, access to monitoring data and collection of new data in a workspace may be temporarily impacted.

Log Analytics workspaces support replication of monitoring data to a workspace to a secondary region.
When replication is enabled, new monitoring data is replicated to the secondary region in addition to the primary region.
Failover to the workspace in the secondary region can be triggered manually.

Some limitations apply:

- Failover occurs by updating DNS records to point to the secondary region.
  As a result, failover won't occur immediately and clients with open connections won't update until a new connection is established.
- Failover is a customer initiated action.
  Failover to the secondary region does not occur automatically.
- Data collection rules need to be updated to point to the system data collection endpoint for ingested data to be replicated.
- See documentation references below for additional limitations and important information.

## RECOMMENDATION

Consider replicating Log Analytics workspaces across regions to improve access to monitoring data in the event of a regional service disruption.

## EXAMPLES

### Configure with Bicep

To deploy log workspaces that pass this rule:

- Set the `properties.replication.enabled` property to `true`.
- Set the `properties.replication.location` property to a supported region in the same region group as the workspace primary region.

For example:

```bicep
resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  properties: {
    replication: {
      enabled: true
      location: secondaryLocation
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}
```

### Configure with Azure template

To deploy log workspaces that pass this rule:

- Set the `properties.replication.enabled` property to `true`.
- Set the `properties.replication.location` property to a supported region in the same region group as the workspace primary region.

For example:

```json
    {
      "type": "Microsoft.OperationalInsights/workspaces",
      "apiVersion": "2025-02-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "replication": {
          "enabled": true,
          "location": "[parameters('secondaryLocation')]"
        },
        "publicNetworkAccessForIngestion": "Enabled",
        "publicNetworkAccessForQuery": "Enabled",
        "retentionInDays": 30,
        "sku": {
          "name": "PerGB2018"
        }
      }
    }
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Replicate workspace across regions](https://learn.microsoft.com/azure/azure-monitor/logs/workspace-replication)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces)
