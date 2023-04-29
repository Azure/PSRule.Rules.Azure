---
reviewed: 2023-04-29
severity: Critical
pillar: Security
category: Data Protection
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.FirewallIPRange/
---

# Limit Redis cache number of IP addresses

## SYNOPSIS

Determine if there is an excessive nunber of permitted IP addresses for the Redis cache.

## DESCRIPTION

Azure Cache for Redis provides the functionality to create firewall rules, limiting the IP addresses that can access the resources.
Normally, you want to limit the number of IP addresses permitted through the firewall.

## RECOMMENDATION

The Redis cache has greater than ten (10) public IP addresses that are permitted network access.
Some rules may not be needed or can be reduced.

## NOTES

This rule is not applicable when Redis is configured to allow private connectivity by setting `properties.publicNetworkAccess` to `Disabled`.
Firewall rules can be used with VNet injected caches, but not private endpoints.

## LINKS

- [How to configure Azure Cache for Redis - Firewall](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-configure#default-redis-server-configuration#firewall)
- [Limitations of firewall rules](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-network-isolation#limitations-of-firewall-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redis/firewallrules)
