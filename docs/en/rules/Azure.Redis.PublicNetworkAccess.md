---
severity: Critical
pillar: Security
category: Application endpoints
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.PublicNetworkAccess/
---

# Limit public network access to Redis cache instances

## SYNOPSIS

Redis cache should disable public network access.

## DESCRIPTION

Public access to redis instances can be disabled. This ensures secure and private connectivity to redis
instances using private endpoints instead.

Private endpoint is a network interface that connects you privately and securely to Azure Cache for
Redis powered by Azure Private Link.

## RECOMMENDATION

Redis cache should disable public network access when public connectivity is not required.

## EXAMPLES

### Configure with Azure template

To disable public network access:

- Set `properties.publicNetworkAccess` to `Disabled`.

For example:

```json
{
  "type": "Microsoft.Cache/Redis",
  "apiVersion": "2021-06-01",
  "name": "[parameters('Redis_name')]",
  "location": "Australia East",
  "properties": {
    "redisVersion": "4.1.14",
    "sku": {
      "name": "Standard",
      "family": "C",
      "capacity": 1
    },
    "enableNonSslPort": false,
    "publicNetworkAccess": "Disabled",
    "redisConfiguration": {
      "maxmemory-reserved": "50",
      "maxfragmentationmemory-reserved": "50",
      "maxmemory-delta": "50"
    }
  }
}
```

### Configure with Bicep

To disable public network access:

- Set `properties.publicNetworkAccess` to `Disabled`.

For example:

```bicep
resource Redis__resource 'Microsoft.Cache/Redis@2021-06-01' = {
  name: Redis_name
  location: 'Australia East'
  properties: {
    redisVersion: '4.1.14'
    sku: {
      name: 'Standard'
      family: 'C'
      capacity: 1
    }
    enableNonSslPort: false
    publicNetworkAccess: 'Disabled'
    redisConfiguration: {
      'maxmemory-reserved': '50'
      'maxfragmentationmemory-reserved': '50'
      'maxmemory-delta': '50'
    }
  }
```

## LINKS

- [Azure Cache for Redis with Azure Private Link](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-private-link)
- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [What is Azure Private Endpoint?](https://docs.microsoft.com/azure/private-link/private-endpoint-overview)
