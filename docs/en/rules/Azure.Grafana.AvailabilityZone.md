---
reviewed: 2025-11-06
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Managed Grafana
resourceType: Microsoft.Dashboard/grafana
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Grafana.AvailabilityZone/
---

# Use zone redundant Managed Grafana workspaces

## SYNOPSIS

Use zone redundant Grafana workspaces in supported regions to improve reliability.

## DESCRIPTION

Azure Managed Grafana supports zone redundancy to provide enhanced resiliency and high availability.
When zone redundancy is enabled, Azure Managed Grafana automatically distributes the service across multiple availability zones within a region.
This configuration ensures that the service remains available even if an entire availability zone experiences an outage.

Zone redundancy can only be configured during the initial workspace creation and cannot be modified afterwards.
Additionally, zone redundancy is only available in regions that support availability zones.

## RECOMMENDATION

Consider enabling zone redundancy for Azure Managed Grafana workspaces deployed in regions that support availability zones to improve service reliability and resilience.

## EXAMPLES

### Configure with Azure template

To deploy Managed Grafana workspaces that pass this rule:

- Set the `properties.zoneRedundancy` property to `Enabled`.

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
    "zoneRedundancy": "Enabled"
  }
}
```

### Configure with Bicep

To deploy Managed Grafana workspaces that pass this rule:

- Set the `properties.zoneRedundancy` property to `Enabled`.

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
    zoneRedundancy: 'Enabled'
  }
}
```

## NOTES

Zone redundancy must be configured during the initial deployment.
It is not possible to modify an existing Managed Grafana workspace to enable zone redundancy after it has been deployed.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Enable zone redundancy in Azure Managed Grafana](https://learn.microsoft.com/azure/managed-grafana/how-to-enable-zone-redundancy)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dashboard/grafana)
