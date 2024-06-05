---
severity: Important
pillar: Performance Efficiency
category: PE:03 Selecting services
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.MinSKU/
---

# Use at least Standard C1 cache instances

## SYNOPSIS

Use Azure Cache for Redis instances of at least Standard C1.

## DESCRIPTION

Azure Cache for Redis supports a range of different scale options.
Basic tier or Standard C0 caches are not suitable for production workloads.

- Basic tier is a single node system with no data replication and no SLA.
- Standard C0 caches used shared resources and subject to noisy neighbor issues.

## RECOMMENDATION

Consider using a minimum of a Standard C1 instance for production workloads.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.sku.name` property to `Premium` or `Standard`.
- Set the `properties.sku.family` property to `P` or `C`.
- Set the `properties.sku.capacity` property to a capacity valid for the SKU `1` or higher.

For example:

```json
{
  "type": "Microsoft.Cache/redis",
  "apiVersion": "2023-04-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "minimumTlsVersion": "1.2",
    "redisVersion": "latest",
    "sku": {
      "name": "Premium",
      "family": "P",
      "capacity": 1
    },
    "redisConfiguration": {
      "maxmemory-reserved": "615"
    },
    "enableNonSslPort": false
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Bicep

To deploy caches that pass this rule:

- Set the `properties.sku.name` property to `Premium` or `Standard`.
- Set the `properties.sku.family` property to `P` or `C`.
- Set the `properties.sku.capacity` property to a capacity valid for the SKU `1` or higher.

For example:

```bicep
resource cache 'Microsoft.Cache/redis@2023-04-01' = {
  name: name
  location: location
  properties: {
    minimumTlsVersion: '1.2'
    redisVersion: 'latest'
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    redisConfiguration: {
      'maxmemory-reserved': '615'
    }
    enableNonSslPort: false
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

<!-- external:avm avm/res/cache/redis skuName -->

## LINKS

- [PE:03 Selecting services](https://learn.microsoft.com/azure/well-architected/performance-efficiency/select-services)
- [Choosing the right tier](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-overview#choosing-the-right-tier)
- [Scaling and memory](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-best-practices-scale#scaling-and-memory)
- [Memory management](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-best-practices-memory-management)
- [SKU sizes](https://azure.microsoft.com/pricing/details/cache/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
