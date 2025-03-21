---
reviewed: 2024-05-01
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Data Explorer
resourceType: Microsoft.Kusto/clusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ADX.SLA/
---

# Use an SLA for Azure Data Explorer clusters

## SYNOPSIS

Use SKUs that include an SLA when configuring Azure Data Explorer (ADX) clusters.

## DESCRIPTION

When choosing a SKU for an ADX cluster you should consider the SLA that is included in the SKU.
ADX clusters offer a range of offerings.
Development SKUs are designed for early non-production use and do not include any SLA.

## RECOMMENDATION

Consider using a production ready SKU that includes a SLA.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set the `sku.tier` property to `Standard`.
- Set the `sku.name` property to non-development SKU such as `Standard_D11_v2`.

For example:

```json
{
  "type": "Microsoft.Kusto/clusters",
  "apiVersion": "2023-08-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_D11_v2",
    "tier": "Standard"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "enableDiskEncryption": true
  }
}
```

### Configure with Bicep

To deploy clusters that pass this rule:

- Set the `sku.tier` property to `Standard`.
- Set the `sku.name` property to non-development SKU such as `Standard_D11_v2`.

For example:

```bicep
resource adx 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: name
  location: location
  sku: {
    name: 'Standard_D11_v2'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableDiskEncryption: true
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure Data Explorer pricing](https://azure.microsoft.com/pricing/details/data-explorer/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters)
