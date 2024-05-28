---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Log Analytics
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LogAnalytics.Replication/
---

# Worskspace replication

## SYNOPSIS

Log Analytics workspaces should have workspace replication enabled to improve service availability.

## DESCRIPTION

Log Analytics workspaces supports workspace replication.
Workspace replication provides availability of the workspace in a secondary region and provides service availability if the primary region goes offline by changing the DNS records to point to the secondary workspace.

The switch to the replicated workspace is an action you trigger manually.

## RECOMMENDATION

Consider deploying an Log Analytics workspace across multiple regions to improve service availability.

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
