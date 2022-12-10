---
severity: Important
pillar: Reliability
category: Requirements
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.Version/
---

# Redis version for Azure Cache for Redis

## SYNOPSIS

Azure Cache for Redis should use the latest supported version of Redis.

## DESCRIPTION

Azure Cache for Redis supports Redis 6. Redis 6 brings new security features and better performance.

Version 4 for Azure Cache for Redis instances will be retired on June 30, 3023.

## RECOMMENDATION

Consider upgrading Redis version for Azure Cache for Redis to the latest supported version (>=6.0).

## EXAMPLES

### Configure with Azure template

To deploy Azure Cache for Redis instances that pass this rule:

- Set the `properties.redisVersion` property to `latest` or `>=6`.

For example:

```json
{
  "type": "Microsoft.Cache/redis",
  "apiVersion": "2022-06-01",
  "name": "[parameters('redisCacheName')]",
  "location": "[parameters('location')]",
  "properties": {
    "redisVersion": "latest",
    "minimumTlsVersion": "[parameters('minTlsVersion')]",
    "sku": {
      "capacity": "[parameters('redisCacheCapacity')]",
      "family": "[parameters('redisCacheFamily')]",
      "name": "[parameters('redisCacheSKU')]"
    }
  }
}
```

### Configure with Bicep

To deploy Azure Cache for Redis instances that pass this rule:

- Set the `properties.redisVersion` property to `latest` or `>=6`.

For example:

```bicep
resource redisCache 'Microsoft.Cache/Redis@2022-06-01' = {
  name: redisCacheName
  location: location
  properties: {
    minimumTlsVersion: minTlsVersion
    redisVersion: 'latest'
    sku: {
      capacity: redisCacheCapacity
      family: redisCacheFamily
      name: redisCacheSKU
    }
  }
}
```

## NOTES

This rule is only applicable for Azure Cache for Redis (OSS Redis) offering.

## LINKS

- [Requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Security operations](https://learn.microsoft.com/azure/architecture/framework/security/security-operations)
- [Set Redis version for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-version)
- [How to upgrade an existing Redis 4 cache to Redis 6](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-upgrade)
- [Retirements from Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-retired-features)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
