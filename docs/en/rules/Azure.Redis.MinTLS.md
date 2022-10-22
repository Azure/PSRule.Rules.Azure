---
severity: Critical
pillar: Security
category: Data protection
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.MinTLS/
ms-content-id: 31240bca-b04f-4267-9c31-cfca4e91cfbf
---

# Redis Cache minimum TLS version

## SYNOPSIS

Redis Cache should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Redis Cache accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Support for TLS 1.0/ 1.1 version will be removed.

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Remove TLS 1.0 and 1.1 from use with Azure Cache for Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-remove-tls-10-11)
- [Configure Azure Cache for Redis settings](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-configure#access-ports)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.cache/redis#RedisCreateProperties)
