---
severity: Critical
pillar: Performance Efficiency
category: Capacity Planning
resource: Cognitive Search
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.Search.SKU.md
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

- Set the `sku.name` to a minimum of basic.

For example:

```json
{
    "apiVersion": "2020-08-01",
    "name": "[parameters('serviceName')]",
    "location": "[parameters('location')]",
    "type": "Microsoft.Search/searchServices",
    "identity": {
        "type": "SystemAssigned"
    },
    "sku": {
        "name": "basic"
    },
    "properties": {
        "replicaCount": 3,
        "partitionCount": 1,
        "hostingMode": "default"
    },
    "tags": {},
    "dependsOn": []
}
```

## LINKS

- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.search/searchservices#sku-object)
- [SLA for Azure Cognitive Search](https://azure.microsoft.com/support/legal/sla/search)
- [Estimate and manage capacity of an Azure Cognitive Search service](https://docs.microsoft.com/azure/search/search-capacity-planning)
- [Choosing the right resources](https://docs.microsoft.com/azure/architecture/framework/scalability/capacity#choosing-the-right-resources)
