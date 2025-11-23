---
reviewed: 2025-11-23
severity: Important
pillar: Operational Excellence
category: OE:05 Infrastructure as code
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.MigrateAMR/
---

# Migrate to Azure Managed Redis

## SYNOPSIS

Azure Cache for Redis is being retired. Migrate to Azure Managed Redis.

## DESCRIPTION

Microsoft has announced the retirement timeline for Azure Cache for Redis across all SKUs.
The recommended replacement going forward is Azure Managed Redis.

Azure Cache for Redis (Basic, Standard, Premium):

- Creation blocked for new customers: April 1, 2026
- Creation blocked for existing customers: October 1, 2026
- Retirement Date: September 30, 2028
- Instances will be disabled starting October 1, 2028

To avoid service disruption, migrate your workloads to Azure Managed Redis.

## RECOMMENDATION

Plan and execute migration from Azure Cache for Redis to Azure Managed Redis before the retirement dates to avoid service disruption.

## LINKS

- [OE:05 Infrastructure as code](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Azure Cache for Redis retirement: What to know and how to prepare](https://techcommunity.microsoft.com/blog/azure-managed-redis/azure-cache-for-redis-retirement-what-to-know-and-how-to-prepare/4458721)
- [Azure Cache for Redis retirement FAQ](https://learn.microsoft.com/azure/azure-cache-for-redis/retirement-faq)
- [Azure Managed Redis documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/managed-redis/managed-redis-overview)
