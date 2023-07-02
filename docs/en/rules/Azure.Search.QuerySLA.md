---
reviewed: 2023-07-02
severity: Important
pillar: Reliability
category: Application design
resource: Cognitive Search
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Search.QuerySLA/
---

# Search query SLA minimum replicas

## SYNOPSIS

Use a minimum of 2 replicas to receive an SLA for index queries.

## DESCRIPTION

Cognitive Search services support _indexing_ and _querying_.
Indexing is the process of loading content into the service to make it searchable.
Querying is the process where a client searches for content by sending queries to the index.

Cognitive Search supports a configurable number of replicas.
Having multiple replicas allows queries and index updates to load balance across multiple replicas.

To receive a Service Level Agreement (SLA) for Search index queries a minimum of 2 replicas is required.

## RECOMMENDATION

Consider increasing the number of replicas to a minimum of 2 to receive an SLA on index query requests.

## EXAMPLES

### Configure with Azure template

To deploy Cognitive Search services that pass this rule:

- Set the `replicaCount` to a minimum of 2.

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

- Set the `replicaCount` to a minimum of 2.

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

- [Resiliency checklist for specific Azure services](https://learn.microsoft.com/azure/architecture/checklist/resiliency-per-service#search)
- [SLA for Azure Cognitive Search](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices)
