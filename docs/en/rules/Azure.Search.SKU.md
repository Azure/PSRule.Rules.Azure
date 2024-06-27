---
reviewed: 2024-03-16
severity: Critical
pillar: Performance Efficiency
category: PE:02 Capacity planning
resource: AI Search
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Search.SKU/
---

# AI Search minimum SKU

## SYNOPSIS

Use the basic and standard tiers for entry level workloads.

## DESCRIPTION

AI Search (Previously known as Cognitive Search) services using the Free tier run on resources shared across multiple subscribers.
The Free tier is only suggested for limited small scale tests such as running code samples or tutorials.

Running more demanding workloads on the Free tier may experience unpredictable performance or issues.

To select a tier for your workload, estimate and test your required capacity.

## RECOMMENDATION

Consider deploying AI Search services using basic or higher tier.

## EXAMPLES

### Configure with Azure template

To deploy AI Search services that pass this rule:

- Set the `sku.name` to a minimum of `basic`.

For example:

```json
{
  "type": "Microsoft.Search/searchServices",
  "apiVersion": "2022-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "standard"
  },
  "properties": {
    "replicaCount": 3,
    "partitionCount": 1,
    "hostingMode": "default"
  }
}
```

### Configure with Bicep

To deploy AI Search services that pass this rule:

- Set the `sku.name` to a minimum of `basic`.

For example:

```bicep
resource search 'Microsoft.Search/searchServices@2022-09-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'standard'
  }
  properties: {
    replicaCount: 3
    partitionCount: 1
    hostingMode: 'default'
  }
}
```

<!-- external:avm avm/res/search/search-service sku -->

## LINKS

- [PE:02 Capacity planning](https://learn.microsoft.com/azure/well-architected/performance-efficiency/capacity-planning)
- [SLA for Azure AI Search](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services)
- [Estimate and manage capacity of a search service](https://learn.microsoft.com/azure/search/search-capacity-planning)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices)
