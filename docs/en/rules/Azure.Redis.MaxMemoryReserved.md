---
severity: Important
pillar: Performance Efficiency
category: Capacity planning
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.MaxMemoryReserved/
---

# Configure cache maxmemory-reserved setting

## SYNOPSIS

Configure `maxmemory-reserved` to reserve memory for non-cache operations.

## DESCRIPTION

Azure Cache for Redis supports configuration of the `maxmemory-reserved` setting.
The `maxmemory-reserved` setting configures the amount of memory reserved for non-cache operations.
Setting this value allows you to have a more consistent experience when your load varies.
This value should be set higher for workloads that are write heavy.

When memory reserved by `maxmemory-reserved`, it is unavailable for storage of cached data.

## RECOMMENDATION

Consider configuring `maxmemory-reserved` to at least 10% of available cache memory.

## LINKS

- [Best practices for Azure Cache for Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-best-practices)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.cache/redis#rediscreateproperties-object)
- [Choosing the right resources](https://learn.microsoft.com/azure/architecture/framework/scalability/capacity#choosing-the-right-resources)
