---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Managed Grafana
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Grafana.Version/
---

# Upgrade Grafana version

## SYNOPSIS

Grafana workspaces should be on Grafana version 10.

## DESCRIPTION

Support for Grafana version 9 within Azure Managed Grafana is deprecated and will retire on 31 August 2024.
To avoid support disruptions, upgrade to Grafana version 10.

## RECOMMENDATION

Upgrade to Grafana version 10 for Azure Managed Grafana workspaces to avoid support disruptions.

## EXAMPLES

### Configure with Azure template

To deploy Azure Managed Grafana workspaces that pass this rule:

- Set the `properties.grafanaMajorVersion` property to `10`.

For example:

```json
{
  "type": "Microsoft.Dashboard/grafana",
  "apiVersion": "2023-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "grafanaMajorVersion": "10"
  }
}
```

### Configure with Bicep

To deploy Azure Managed Grafana workspaces that pass this rule:

- Set the `properties.grafanaMajorVersion` property to `10`.

For example:

```bicep
resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    grafanaMajorVersion: '10'
  }
}
```

### Configure with Azure CLI

```bash
az grafana update --name <azure-managed-grafana-workspace> --major-version 10
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Update to using Grafana version 10 for Azure Managed Grafana](https://azure.microsoft.com/updates/action-recommended-update-to-using-grafana-version-10-for-azure-managed-grafana)
- [Upgrade to Grafana 10](https://learn.microsoft.com/azure/managed-grafana/how-to-upgrade-grafana-10)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.dashboard/grafana)
