---
reviewed: 2025-03-25
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Managed Grafana
resourceType: Microsoft.Dashboard/grafana
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Grafana.Version/
---

# Azure Managed Grafana uses a deprecated version of Grafana

## SYNOPSIS

Grafana workspaces should be on Grafana version 10.

## DESCRIPTION

Support for Grafana version 10 within Azure Managed Grafana is deprecated.
Azure Managed Grafana supports Grafana version 11.
In August 2025, all Grafana workspaces running Grafana version 10 will be automatically upgraded to Grafana version 11.

However, Grafana 11 introduces several breaking changes.
To avoid support disruptions, familiarize yourself with the breaking changes and start planning your upgrade.
Plan to complete your upgrade to Grafana 11 before the deadline.

## RECOMMENDATION

Consider familiarize yourself with the breaking changes introduced in Grafana 11,
and plan to upgrade your Azure Managed Grafana workspaces before the deadline to avoid support disruptions.

## EXAMPLES

### Configure with Bicep

To deploy Azure Managed Grafana workspaces that pass this rule:

- Set the `properties.grafanaMajorVersion` property to `11`.

For example:

```bicep
resource grafana 'Microsoft.Dashboard/grafana@2024-10-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    grafanaMajorVersion: '11'
    zoneRedundancy: 'Enabled'
  }
}
```

### Configure with Azure template

To deploy Azure Managed Grafana workspaces that pass this rule:

- Set the `properties.grafanaMajorVersion` property to `11`.

For example:

```json
{
  "type": "Microsoft.Dashboard/grafana",
  "apiVersion": "2024-10-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "grafanaMajorVersion": "11",
    "zoneRedundancy": "Enabled"
  }
}
```

### Configure with Azure CLI

```bash
az grafana update --name <azure-managed-grafana-workspace> --major-version 11
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Upgrade to Grafana 11](https://learn.microsoft.com/azure/managed-grafana/how-to-upgrade-grafana-11)
- [Breaking changes in Grafana v11.0](https://grafana.com/docs/grafana/latest/breaking-changes/breaking-changes-v11-0/)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.dashboard/grafana)
