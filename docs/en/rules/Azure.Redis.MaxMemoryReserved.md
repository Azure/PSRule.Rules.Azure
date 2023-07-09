---
reviewed: 2023-07-08
severity: Important
pillar: Performance Efficiency
category: Application capacity
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.MaxMemoryReserved/
---

# Configure cache maxmemory-reserved setting

## SYNOPSIS

Configure `maxmemory-reserved` to reserve memory for non-cache operations.

## DESCRIPTION

Azure Cache for Redis supports configuration of the `maxmemory-reserved` setting.
The `maxmemory-reserved` setting configures the amount of memory reserved for non-cache operations.
Non-cache operations include background tasks, eviction, and compaction.

By reserving memory for these operations, you prevent Redis cache from using all available memory for cache.
If enough memory is not reserved for these operations it can lead to performance degradation and instability.

Setting this value allows you to have a more consistent experience when your load varies.
This value should be set higher for workloads that are write heavy.

When memory reserved by `maxmemory-reserved`, it is unavailable for storage of cached data.

## RECOMMENDATION

Consider configuring `maxmemory-reserved` to at least 10% of available cache memory.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.redisConfiguration.maxmemory-reserved` property to at least 10% of the cache memory.

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

- Set the `properties.redisConfiguration.maxmemory-reserved` property to at least 10% of the cache memory.

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

## LINKS

- [Choose the right resources](https://learn.microsoft.com/azure/well-architected/scalability/design-capacity#choose-the-right-resources)
- [Choosing the right tier](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-overview#choosing-the-right-tier)
- [Scaling and memory](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-best-practices-scale#scaling-and-memory)
- [Memory management](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-best-practices-memory-management)
- [SKU sizes](https://azure.microsoft.com/pricing/details/cache/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
