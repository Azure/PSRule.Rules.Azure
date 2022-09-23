---
reviewed: 2022-09-22
severity: Awareness
pillar: Security
category: Network security and containment
resource: zure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.FirewallRuleCount/
---

# Cleanup Redis cache firewall rules

## Synopsis

Determine if there is an excessive number of firewall rules for the Redis cache.

## Description

Azure Cache for Redis provides the functionality to create firewall rules, limiting the IP addresses that can access the resources. Normally, you want to limit the number of firewall rules.

## Recommendation

The Redis cache has more than ten (10) firewall rules. Some rules may not be needed.

## Examples

### Configure with Azure template

To deploy Redis Cache that pass this rule:

- Set the `properties.startIP` property to the start of the IP address range.
- Set the `properties.endIP` property to the end of the IP address range.

```json
{
  "type": "Microsoft.Cache/redis/firewallRules",
  "apiVersion": "2022-05-01",
  "name": "string",
  "properties": {
    "startIP": "string",
    "endIP": "string"
  }
}
```

### Configure with Bicep

To deploy Redis Cache that pass this rule:

- Set the `properties.startIP` property to the start of the IP address range.
- Set the `properties.endIP` property to the end of the IP address range.

```
resource symbolicname 'Microsoft.Cache/redis/firewallRules@2022-05-01' = {
  name: 'string'
  parent: resourceSymbolicName
  properties: {
    startIP: 'string'
    endIP: 'string'
  }
}
```

## Links

- [How to configure Azure Cache for Redis - Firewall](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-configure#default-redis-server-configuration#firewall)
- [Microsoft.Cache redis/firewallRules](https://docs.microsoft.com/azure/templates/microsoft.cache/2022-05-01/redis/firewallrules)

```

```
