---
reviewed: 2024-10-12
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.EntraID/
---

# Use Entra ID authentication with cache instances

## SYNOPSIS

Use Entra ID authentication with cache instances.

## DESCRIPTION

Azure Cache for Redis by default requires that all requests be authenticated.
Two methods are supported for authenticating and authorizing requests to Redis cache instances.

- **Access keys** - Cryptographic keys are secret similar to a shared password,
  and as a result have a number of limitations that impact security and maintainability.
  - Access keys have a long number of characters, so are not easily guessable but once exposed grant full access.
  - Auditing based on user or application is not possible when using access keys.
  - Each access key must be stored securely within any applications or scripts that use it.
    This can introduce additional dependencies and code to maintain, that might not normally be required if using Entra ID.
    Azure Key Vault provides a secure storage for access keys as a secret.
  - You have two keys (primary/ secondary) to manage, each should be rotated independently on a regular basis.
    Rotation should occur regularly using automation with a documented manual process as a backup.
- **Microsoft Entra ID** - An OAuth2 access token issued by Microsoft Entra ID provides advantages over access keys including:
  - More granular access control instead of only full access.
  - Strong identity protection methods such as Multi-Factor Authentication (MFA) and conditional access.
  - Central management and auditing.

Currently Redis Enterprise and Redis Enterprise Flash tiers are not supported.
Entra ID authentication is supported on `Basic`, `Standard`, and `Premium` tiers.

## RECOMMENDATION

Consider configuring and using Microsoft Entra ID to authenticate all connections to Redis cache instances.

## EXAMPLES

### Configure with Azure template

To deploy cache instances that pass this rule:

- Set the `properties.redisConfiguration.aad-enabled` to `"True"`.

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

To deploy cache instances that pass this rule:

- Set the `properties.redisConfiguration.aad-enabled` to `'True'`.

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

<!-- external:avm avm/res/cache/redis redisConfiguration -->

## NOTES

Microsoft Entra ID based authentication isn't supported in the Enterprise/ Enterprise Flash tiers.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Use Microsoft Entra ID for cache authentication](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication)
- [Configure role-based access control with Data Access Policy](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-configure-role-based-access-control)
- [Azure security baseline for Azure Cache for Redis](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.cache/redis#rediscommonpropertiesredisconfiguration)
