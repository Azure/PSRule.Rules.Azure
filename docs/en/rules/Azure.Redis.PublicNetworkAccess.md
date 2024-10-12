---
reviewed: 2023-07-08
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.PublicNetworkAccess/
---

# Use private endpoints with Azure Cache for Redis

## SYNOPSIS

Redis cache should disable public network access.

## DESCRIPTION

When using Azure Cache for Redis, you can configure the cache to be private or accessible from the public Internet.
By default, the cache is configured to be accessible from the public Internet.

To limit network access to the cache you can use firewall rules or private endpoints.
Using private endpoints with Azure Cache for Redis is the recommend approach for most scenarios.

Use private endpoints to improve the security posture of your Redis cache and reduce the risk of data breaches.

A private endpoint provides secure and private connectivity to Redis instances by:

- Using a private IP address from your VNET.
- Blocking all traffic from public networks.

If you are using VNET injection, it is recommended to migrate to private endpoints.

## RECOMMENDATION

Consider using private endpoints to limit network connectivity to the cache and help reduce data exfiltration risks.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

<!-- external:avm avm/res/cache/redis publicNetworkAccess -->

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Azure Cache for Redis with Azure Private Link](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-private-link)
- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Migrate from VNet injection caches to Private Link caches](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-vnet-migration)
- [What is Azure Private Endpoint?](https://learn.microsoft.com/azure/private-link/private-endpoint-overview)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#ns-2-secure-cloud-services-with-network-controls)
- [Azure Policy Regulatory Compliance controls for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/security-controls-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
