---
severity: Important
pillar: Operational Excellence
category: Infrastructure provisioning
resource: Azure Cache for Redis
resourceType: Microsoft.Cache/redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.Retirement/
---

# Migrate to Azure Managed Redis

## SYNOPSIS

Azure Cache for Redis is on the retirement path. Migrate to Azure Managed Redis.

## DESCRIPTION

Microsoft has announced the retirement timeline for Azure Cache for Redis across all SKUs.
The recommended replacement going forward is Azure Managed Redis.

Azure Cache for Redis will be retired according to the following timeline:

- Basic and Standard SKUs will be retired on September 30, 2025.
- Premium SKU will be retired on September 30, 2027.

To avoid service disruption, migrate your workloads to Azure Managed Redis.

Azure Managed Redis provides several advantages:

- **Improved Performance**: Enhanced throughput and lower latency.
- **Enhanced Security**: Built-in support for Azure Active Directory authentication and managed identities.
- **Better Availability**: Higher availability SLA and improved zone redundancy support.
- **Simplified Management**: Streamlined configuration and maintenance with automated updates.
- **Cost Optimization**: More predictable pricing and better resource utilization.

## RECOMMENDATION

Plan and execute migration from Azure Cache for Redis to Azure Managed Redis before the retirement dates to avoid service disruption.

## EXAMPLES

### Configure with Azure template

Azure Managed Redis uses a different resource type. Update your templates to use `Microsoft.Cache/redisEnterprise` instead of `Microsoft.Cache/Redis`.

For example:

```json
{
  "type": "Microsoft.Cache/redisEnterprise",
  "apiVersion": "2023-11-01",
  "name": "[parameters('redisCacheName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Enterprise_E10",
    "capacity": 2
  },
  "zones": [
    "1",
    "2",
    "3"
  ],
  "properties": {
    "minimumTlsVersion": "1.2"
  }
}
```

### Configure with Bicep

Azure Managed Redis uses a different resource type. Update your Bicep files to use `Microsoft.Cache/redisEnterprise` instead of `Microsoft.Cache/Redis`.

For example:

```bicep
resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2023-11-01' = {
  name: redisCacheName
  location: location
  sku: {
    name: 'Enterprise_E10'
    capacity: 2
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    minimumTlsVersion: '1.2'
  }
}
```

## NOTES

This rule will fail for all Azure Cache for Redis resources as part of informing you about the retirement path.
Consider migrating to Azure Managed Redis before the retirement dates.

## LINKS

- [Infrastructure provisioning](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Azure Cache for Redis retirement: What to know and how to prepare](https://techcommunity.microsoft.com/blog/azure-managed-redis/azure-cache-for-redis-retirement-what-to-know-and-how-to-prepare/4458721)
- [Azure Cache for Redis retirement FAQ](https://learn.microsoft.com/azure/azure-cache-for-redis/retirement-faq)
- [Azure Managed Redis documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/managed-redis/managed-redis-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redisenterprise)
