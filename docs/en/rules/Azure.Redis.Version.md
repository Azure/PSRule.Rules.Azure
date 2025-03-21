---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.Version/
---

# Redis version for Azure Cache for Redis

## SYNOPSIS

Azure Cache for Redis should use the latest supported version of Redis.

## DESCRIPTION

Azure Cache for Redis supports Redis 6.
Redis 6 brings new security features and better performance.

Version 4 for Azure Cache for Redis instances will be retired on June 30, 3023.

## RECOMMENDATION

Consider upgrading Redis version for Azure Cache for Redis to the latest supported version (>=6.0).

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.redisVersion` property to `latest` or `6`.

For example:

```json
{
  "type": "Microsoft.Cache/redis",
  "apiVersion": "2024-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "redisVersion": "6",
    "sku": {
      "name": "Premium",
      "family": "P",
      "capacity": 1
    },
    "redisConfiguration": {
      "aad-enabled": "True",
      "maxmemory-reserved": "615"
    },
    "enableNonSslPort": false,
    "publicNetworkAccess": "Disabled"
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

- Set the `properties.redisVersion` property to `latest` or `6`.

For example:

```bicep
resource cache 'Microsoft.Cache/redis@2024-03-01' = {
  name: name
  location: location
  properties: {
    redisVersion: '6'
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    redisConfiguration: {
      'aad-enabled': 'True'
      'maxmemory-reserved': '615'
    }
    enableNonSslPort: false
    publicNetworkAccess: 'Disabled'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

<!-- external:avm avm/res/cache/redis redisVersion -->

## NOTES

This rule is only applicable for Azure Cache for Redis (OSS Redis) offering.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Security operations](https://learn.microsoft.com/azure/architecture/framework/security/security-operations)
- [Set Redis version for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-version)
- [How to upgrade an existing Redis 4 cache to Redis 6](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-upgrade)
- [Retirements from Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-retired-features)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
