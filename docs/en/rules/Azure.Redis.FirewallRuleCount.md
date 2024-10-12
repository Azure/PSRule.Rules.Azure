---
reviewed: 2023-07-08
severity: Awareness
pillar: Security
category: SE:08 Hardening resources
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.FirewallRuleCount/
---

# Cleanup Redis cache firewall rules

## SYNOPSIS

Determine if there is an excessive number of firewall rules for the Redis cache.

## DESCRIPTION

When using Azure Cache for Redis, injected into a VNET you are able to create firewall rules to limit access to the cache.
Each firewall rules specifies a range of IP addresses that are allowed to access the cache.

If no firewall rules are set and public access is not disabled, then all IP addresses are allowed to access the cache.
By default, the cache is configured to allow access from all IP addresses.

Consider using private endpoints to limit access to the cache.
If this is not possible, use firewall rules to limit access to the cache.
However, avoid using overly permissive firewall rules that are:

- Not needed.
- Too broad.
- Too many.

## RECOMMENDATION

The Redis cache has more than ten (10) firewall rules.
Some rules may not be needed.

## EXAMPLES

### Configure with Azure template

To deploy caches that pass this rule:

- Set the `properties.startIP` property to the start of the IP address range.
- Set the `properties.endIP` property to the end of the IP address range.
- Configure a minimum number of firewall rules.
  This rule will fail if more then ten (10) firewall rules are configured.

```json
{
  "type": "Microsoft.Cache/redis/firewallRules",
  "apiVersion": "2023-04-01",
  "name": "[format('{0}/{1}', parameters('name'), 'allow-on-premises')]",
  "properties": {
    "startIP": "10.0.1.1",
    "endIP": "10.0.1.31"
  },
  "dependsOn": [
    "cache"
  ]
}
```

### Configure with Bicep

To deploy caches that pass this rule:

- Set the `properties.startIP` property to the start of the IP address range.
- Set the `properties.endIP` property to the end of the IP address range.
- Configure a minimum number of firewall rules.
  This rule will fail if more then ten (10) firewall rules are configured.

```bicep
resource rule 'Microsoft.Cache/redis/firewallRules@2023-04-01' = {
  parent: cache
  name: 'allow-on-premises'
  properties: {
    startIP: '10.0.1.1'
    endIP: '10.0.1.31'
  }
}
```

## NOTES

This rule is not applicable when Redis is configured to allow private connectivity by setting `properties.publicNetworkAccess` to `Disabled`.
Firewall rules can be used with VNet injected caches, but not private endpoints.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Azure best practices for network security](https://learn.microsoft.com/azure/security/fundamentals/network-best-practices)
- [Azure Cache for Redis network isolation options](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-network-isolation)
- [Limitations of firewall rules](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-network-isolation#limitations-of-firewall-rules)
- [Migrate from VNet injection caches to Private Link caches](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-vnet-migration)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis/firewallrules)
