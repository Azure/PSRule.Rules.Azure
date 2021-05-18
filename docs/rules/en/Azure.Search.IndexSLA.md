---
severity: Important
pillar: Reliability
category: Availability
resource: Cognitive Search
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Search.IndexSLA.md
---

# Search index update SLA minimum replicas

## SYNOPSIS

Use a minimum of 3 replicas to receive an SLA for query and index updates.

## DESCRIPTION

Cognitive Search services support _indexing_ and _querying_.
Indexing is the process of loading content into the service to make it searchable.
Querying is the process where a client searches for content by sending queries to the index.

Cognitive Search supports a configurable number of replicas.
Having multiple replicas allows queries and index updates to load balance across multiple replicas.

To receive a Service Level Agreement (SLA) for Search index updates a minimum of 3 replicas is required.

## RECOMMENDATION

Consider increasing the number of replicas to a minimum of 3 to receive an SLA on index update requests.

## EXAMPLES

### Configure with Azure template

To deploy Cognitive Search services that pass this rule:

- Set the `replicaCount` to a minimum of 3.

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
        "name": "[parameters('sku')]"
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

- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.search/searchservices#searchserviceproperties-object)
- [SLA for Azure Cognitive Search](https://azure.microsoft.com/support/legal/sla/search)
- [Resiliency checklist for specific Azure services](https://docs.microsoft.com/azure/architecture/checklist/resiliency-per-service#search)
