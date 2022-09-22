---
reviewed: 2022-09-22
severity: Critical
pillar: Security
category: Data Protection
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.FirewallIPRange/
---

# Limit Redis cache number of IP addresses

## Synopsis

Determine if there is an excessive nunber of permitted IP addresses for the Redis cache.

## Description

Azure Cache for Redis provides the functionality to create firewall rules, limiting the IP addresses that can access the resources. Normally, you want to limit the number of IP addresses permitted through the firewall.

## Recommednation

The Redis cache has greater than ten (10) public IP addresses that are permitted network access. Some rules may not be needed or can be reduced.

## Links

- [How to configure Azure Cache for Redis - Firewall](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-configure#default-redis-server-configuration#firewall)
- [Microsoft.Cache redis/firewallRules](https://docs.microsoft.com/azure/templates/microsoft.cache/2022-05-01/redis/firewallrules)
