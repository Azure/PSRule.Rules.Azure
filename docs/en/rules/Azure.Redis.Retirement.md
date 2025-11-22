---
reviewed: 2025-11-22
severity: Important
pillar: Operational Excellence
category: OE:05 Infrastructure as code
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.Retirement/
---

# Migrate to Azure Managed Redis

## SYNOPSIS

Azure Cache for Redis is being retired. Migrate to Azure Managed Redis.

## DESCRIPTION

Microsoft has announced the retirement timeline for Azure Cache for Redis across all SKUs.
The recommended replacement going forward is Azure Managed Redis.

Azure Cache for Redis will be retired according to the following timeline:

- Basic and Standard SKUs will be retired on September 30, 2025.
- Premium SKU will be retired on September 30, 2027.

To avoid service disruption, migrate your workloads to Azure Managed Redis.

## RECOMMENDATION

Plan and execute migration from Azure Cache for Redis to Azure Managed Redis before the retirement dates to avoid service disruption.

## NOTES

This rule will fail for all Azure Cache for Redis resources as part of informing you about the retirement path.
Consider migrating to Azure Managed Redis before the retirement dates.

## LINKS

- [Infrastructure as code](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Azure Cache for Redis retirement: What to know and how to prepare](https://techcommunity.microsoft.com/blog/azure-managed-redis/azure-cache-for-redis-retirement-what-to-know-and-how-to-prepare/4458721)
- [Azure Cache for Redis retirement FAQ](https://learn.microsoft.com/azure/azure-cache-for-redis/retirement-faq)
- [Azure Managed Redis documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/managed-redis/managed-redis-overview)
