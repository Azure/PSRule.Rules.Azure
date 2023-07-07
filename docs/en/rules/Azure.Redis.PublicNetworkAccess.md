---
severity: Critical
pillar: Security
category: Connectivity
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.PublicNetworkAccess/
---

# Limit public network access to Redis cache instances

## SYNOPSIS

Redis cache should disable public network access.

## DESCRIPTION

Public access to redis instances can be disabled.
This ensures secure and private connectivity to redis instances using private endpoints instead.

Private endpoint is a network interface that connects you privately and securely to Azure Cache for
Redis powered by Azure Private Link.

## RECOMMENDATION

Redis cache should disable public network access when public connectivity is not required.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set `properties.publicNetworkAccess` property to `Disabled`.

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

- Set `properties.publicNetworkAccess` property to `Disabled`.

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
    publicNetworkAccess: 'Disabled'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## LINKS

- [Azure services for securing network connectivity](https://learn.microsoft.com/azure/well-architected/security/design-network-connectivity)
- [Azure Cache for Redis with Azure Private Link](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-private-link)
- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [What is Azure Private Endpoint?](https://learn.microsoft.com/azure/private-link/private-endpoint-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
