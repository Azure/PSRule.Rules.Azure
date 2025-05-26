---
reviewed: 2025-05-25
severity: Important
pillar: Security
category: SE:01 Security baseline
resource: Azure Monitor Logs
resourceType: Microsoft.OperationalInsights/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Log.ReplicaLocation/
---

# Logs workspace replica location is not allowed

## SYNOPSIS

The replication location determines the country or region where the data is stored and processed.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements or legal obligations that limit where data can be stored or processed.
This is commonly known as data residency.

Azure Monitor Logs workspaces (previously Log Analytics workspaces) can be replicated to a secondary region.
When replication is enabled, new monitoring data is replicated to the secondary region in addition to the primary region.
Data in the secondary region is stored, processed, and subject to local legal requirements in that region.

To align with your organizational requirements, you may choose to limit the regions that replication can be configured.
This allows you to ensure that resources replicate to regions that meet your data residency requirements.

Some resources, particularly those related to preview services or features, may not be available in all regions.

## RECOMMENDATION

Consider configuring Log workspace replication to allowed regions to align with your organizational requirements.

## EXAMPLES

### Configure with Bicep

To deploy log workspaces that pass this rule:

- Set the `properties.replication.location` property to an allowed region, in the list of supported regions.

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

- Set the `properties.replication.location` property to an allowed region, in the list of supported regions.

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

## NOTES

This rule requires one or more allowed regions to be configured.
By default, all regions are allowed.

### Rule configuration

<!-- module:config rule AZURE_RESOURCE_ALLOWED_LOCATIONS -->

To configure this rule set the `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value to a set of allowed regions.

For example:

```yaml
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS:
  - australiaeast
  - australiasoutheast
```

If you configure this `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value,
also consider setting `AZURE_RESOURCE_GROUP` the configuration value to when resources use the location of the resource group.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    location: australiaeast
```

## LINKS

- [SE:01 Security baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [Replicate workspace across regions](https://learn.microsoft.com/azure/azure-monitor/logs/workspace-replication)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces)
