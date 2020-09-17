---
severity: Important
pillar: Performance Efficiency
category: Capacity Planning
resource: Azure Cache for Redis
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Redis.MinSKU.md
---

# Use at least Standard C1 cache instances

## SYNOPSIS

Use Azure Cache for Redis instances of at least Standard C1.

## DESCRIPTION

Azure Cache for Redis supports a range of different scale options.
Basic tier or Standard C0 caches are not suitable for production workloads.

- Basic tier is a single node system with no data replication and no SLA.
- Standard C0 caches used shared resources and subject to noisy neighbor issues.

## RECOMMENDATION

Consider using a minimum of a Standard C1 instance for production workloads.

## LINKS

- [Best practices for Azure Cache for Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices)
- [Azure Cache for Redis pricing](https://azure.microsoft.com/pricing/details/cache/)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.cache/redis#sku-object)
- [Choosing the right resources](https://docs.microsoft.com/en-gb/azure/architecture/framework/scalability/capacity#choosing-the-right-resources)
