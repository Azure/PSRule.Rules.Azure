---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.EntraID/
---

# Use Entra ID authentication with cache instances

## SYNOPSIS

Use Entra ID authentication with cache instances.

## DESCRIPTION

Azure Cache for Redis provides two authentication methods for accessing cache instances: access keys and Microsoft Entra ID.
Entra ID authentication offers centralized identity management and enhanced security features.

Some advantages of using Entra ID authentication over access keys include:

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional access policies with Conditional Access.

Disabling local authentication methods is not supported.
However, regenerating the access keys will invalidate any previously used access keys, rendering them unusable for accessing the cache instance.

See documentation references below for additional limitations and important information.

## RECOMMENDATION

Consider using Entra ID authentication with cache instances.

## EXAMPLES

### Configure with Azure template

To deploy cache instances that pass this rule:

- Set the `properties.redisConfiguration.aad-enabled` to `'True'`.

For example:

```json
{
  "type": "Microsoft.Cache/redis",
  "apiVersion": "2023-08-01",
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
      "aad-enabled": "True"
    }
  }
}
```

### Configure with Bicep

To deploy cache instances that pass this rule:

- Set the `properties.redisConfiguration.aad-enabled` to `'True'`.

For example:

```bicep
resource cache 'Microsoft.Cache/redis@2023-08-01' = {
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
      'aad-enabled': 'True'
    }
  }
}
```

## NOTES

Microsoft Entra ID based authentication isn't supported in the Enterprise tiers of Azure Cache for Redis Enterprise.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Use Microsoft Entra ID for cache authentication](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication)
- [Configure role-based access control with Data Access Policy](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-configure-role-based-access-control)
- [Azure security baseline for Azure Cache for Redis](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.cache/redis#rediscommonpropertiesredisconfiguration)
