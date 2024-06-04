---
severity: Critical
pillar: Security
category: Encryption
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.NonSslPort/
ms-content-id: cf433410-8a30-4b74-b046-0b8c7c708368
---

# Use secure connections to Redis instances

## SYNOPSIS

Azure Cache for Redis should only accept secure connections.

## DESCRIPTION

Azure Cache for Redis can be configured to accept encrypted and unencrypted connections.
By default, only encrypted communication is accepted.
To accept unencrypted connections, the non-SSL port must be enabled.
Using the non-SSL port for Azure Redis cache allows unencrypted communication to Redis cache.

Unencrypted communication can potentially allow disclosure of sensitive information to an untrusted party.

## RECOMMENDATION

Consider only using secure connections to Redis cache by enabling SSL and disabling the non-SSL port.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.enableNonSslPort` property to `false`.

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

- Set the `properties.enableNonSslPort` property to `false`.

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

<!-- external:avm avm/res/cache/redis enableNonSslPort -->

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [How to configure Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-configure#access-ports)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Azure Policy Regulatory Compliance controls for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/security-controls-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
