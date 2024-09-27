---
reviewed: 2024-09-27
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Cache for Redis Enterprise
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RedisEnterprise.MinTLS/
---

# Redis Cache minimum TLS version

## SYNOPSIS

Redis Cache should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Redis Cache accepts was previously configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Depending on when your cache was deployed you may be using a default that specifies an older version of TLS.
Any new deployments do not allow TLS 1.0 or 1.1 to be specified, however existing cache deployment may require updating.

Support for TLS 1.0 and TLS 1.1 will be removed in 1 November 2024.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
No action is required for new cache deployments, which only support a minimum of TLS 1.2.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.minimumTlsVersion` property to a minimum of `1.2` for existing caches with an old version of TLS configured.
  It is not possible to set the `properties.minimumTlsVersion` on new cache deployments.
  New cache deployments only support a minimum TLS version of 1.2.

For example:

```json
{
  "type": "Microsoft.Cache/redisEnterprise",
  "apiVersion": "2024-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Enterprise_E10"
  },
  "properties": {
    "minimumTlsVersion": "1.2"
  }
}
```

### Configure with Bicep

To deploy caches that pass this rule:

- Set the `properties.minimumTlsVersion` property to a minimum of `1.2` for existing caches with an old version of TLS configured.
  It is not possible to set the `properties.minimumTlsVersion` on new cache deployments.
  New cache deployments only support a minimum TLS version of 1.2.

For example:

```bicep
resource cache 'Microsoft.Cache/redisEnterprise@2024-02-01' = {
  name: name
  location: location
  sku: {
    name: 'Enterprise_E10'
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
}
```

### Configure with Azure CLI

To deploy caches that pass this rule:

- Use the `--set` parameter.
  This parameter only applies to old cache deployments using TLS 1.0 or TLS 1.1.

For example:

```bash
az redis update -n '<name>' -g '<resource_group>' --set minimumTlsVersion=1.2
```

### Configure with Azure PowerShell

To deploy caches that pass this rule:

- Use the `-MinimumTlsVersion` parameter.
  This parameter only applies to old cache deployments using TLS 1.0 or TLS 1.1.

For example:

```powershell
Set-AzRedisCache -Name '<name>' -MinimumTlsVersion '1.2'
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Remove TLS 1.0 and 1.1 from use with Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-remove-tls-10-11)
- [Configure Azure Cache for Redis settings](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-configure#access-ports)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redisenterprise)
