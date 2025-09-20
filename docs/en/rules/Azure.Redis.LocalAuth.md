---
reviewed: 2025-09-21
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.LocalAuth/
---

# Azure Cache for Redis access keys are enabled

## SYNOPSIS

Access keys allow depersonalized access to Azure Cache for Redis using a shared secret.

## DESCRIPTION

Azure Cache for Redis supports two forms of authentication:
access keys and Entra ID (previously Azure AD) authentication.
Access keys provide full access to the cache without granular permission controls.
When access keys are used, anyone with the key can perform any operation on the cache.

Using Entra ID authentication offers several advantages:

- **Centralized identity management**: Consistent authentication across all Azure services.
- **Granular access control**: Use role-based access control (RBAC) to define specific permissions.
- **Enhanced security**: No shared secrets that need to be rotated and managed.
- **Auditability**: Better tracking of who accessed the cache and when.

You can disable access key authentication by setting the `disableAccessKeyAuthentication` property to `true`.
When disabled, only Entra ID authentication will be accepted for connections to the cache.

Before you disable access keys:

- Ensure that Microsoft Entra authentication is enabled and you have at least one Redis User configured.
- Ensure all applications connecting to your cache instance switch to using Microsoft Entra Authentication.
- Consider disabling access during the scheduled maintenance window for your cache instance.

For geo-replicated caches, you must:

- Unlink the caches.
- Disable access keys.
- Relink the caches.

## RECOMMENDATION

Consider disabling access key authentication on Azure Cache for Redis and using Entra ID authentication exclusively.

## EXAMPLES

### Configure with Bicep

To deploy caches that pass this rule:

- Set the `properties.disableAccessKeyAuthentication` property to `true`.

For example:

```bicep
resource cache 'Microsoft.Cache/redis@2024-11-01' = {
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
    disableAccessKeyAuthentication: true
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

<!-- external:avm avm/res/cache/redis disableAccessKeyAuthentication -->

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.disableAccessKeyAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Cache/redis",
  "apiVersion": "2024-11-01",
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
    "publicNetworkAccess": "Disabled",
    "disableAccessKeyAuthentication": true
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Cache for Redis should not use access keys for authentication](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cache/RedisCache_DisableAccessKeysAuth_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/3827af20-8f80-4b15-8300-6db0873ec901`

## NOTES

See the Azure Cache for Redis documentation for requirements and limitations for configuring this feature.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Use Microsoft Entra ID for cache authentication](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication)
- [Disable access key authentication on your cache](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication#disable-access-key-authentication-on-your-cache)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)
