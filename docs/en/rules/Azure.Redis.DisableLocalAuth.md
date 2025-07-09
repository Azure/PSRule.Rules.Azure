---
reviewed: 2024-12-19
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.DisableLocalAuth/
---

# Azure Cache for Redis access keys are enabled

## SYNOPSIS

Authenticate Redis Cache clients with Entra ID identities.

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

## RECOMMENDATION

Consider disabling access key authentication on Azure Cache for Redis and using Entra ID authentication exclusively.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.disableAccessKeyAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Cache/Redis",
  "apiVersion": "2024-04-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "name": "Standard",
      "family": "C",
      "capacity": 1
    },
    "redisConfiguration": {
      "aad-enabled": "true"
    },
    "enableNonSslPort": false,
    "redisVersion": "6",
    "disableAccessKeyAuthentication": true
  }
}
```

### Configure with Bicep

To deploy caches that pass this rule:

- Set the `properties.disableAccessKeyAuthentication` property to `true`.

For example:

```bicep
resource cache 'Microsoft.Cache/Redis@2024-04-01-preview' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'Standard'
      family: 'C'
      capacity: 1
    }
    redisConfiguration: {
      'aad-enabled': 'true'
    }
    enableNonSslPort: false
    redisVersion: '6'
    disableAccessKeyAuthentication: true
  }
}
```

<!-- external:avm avm/res/cache/redis disableAccessKeyAuthentication -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Configure Azure Cache for Redis to disable local authentication](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cache/RedisCache_DisableLocalAuth_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/470baccb-7e51-4549-8b1a-3e5be069f663`

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Use Microsoft Entra ID for cache authentication](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication)
- [Disable access key authentication on your cache](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication#disable-access-key-authentication-on-your-cache)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis)