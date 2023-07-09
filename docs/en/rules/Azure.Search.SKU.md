---
reviewed: 2023-07-02
severity: Critical
pillar: Performance Efficiency
category: Application capacity
resource: Cognitive Search
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Search.SKU/
---

# Cognitive Search minimum SKU

## SYNOPSIS

Use the basic and standard tiers for entry level workloads.

## DESCRIPTION

Cognitive Search services using the Free tier run on resources shared across multiple subscribers.
The Free tier is only suggested for limited small scale tests such as running code samples or tutorials.

Running more demanding workloads on the Free tier may experience unpredictable performance or issues.

To select a tier for your workload, estimate and test your required capacity.

## RECOMMENDATION

Consider deploying Cognitive Search services using basic or higher tier.

## EXAMPLES

### Configure with Azure template

To deploy Cognitive Search services that pass this rule:

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

To deploy Cognitive Search services that pass this rule:

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

## LINKS

- [Choose the right resources](https://learn.microsoft.com/azure/architecture/framework/scalability/design-capacity#choose-the-right-resources)
- [SLA for Azure Cognitive Search](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services)
- [Estimate and manage capacity of an Azure Cognitive Search service](https://learn.microsoft.com/azure/search/search-capacity-planning)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices)
