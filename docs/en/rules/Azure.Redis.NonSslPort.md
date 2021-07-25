---
severity: Critical
pillar: Security
category: Data protection
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.NonSslPort/
ms-content-id: cf433410-8a30-4b74-b046-0b8c7c708368
---

# Use secure connections to Redis instances

## SYNOPSIS

Azure Cache for Redis should only accept secure connections.

## DESCRIPTION

Azure Cache for Redis is configured to accept unencrypted connections using a non-SSL port.
Unencrypted connections are disabled by default.

Unencrypted communication to Redis Cache could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Cache for Redis should be configured to only accept secure connections.

When the non-SSL port is enabled, encrypted and unencrypted connections are permitted.
To prevent unencrypted connections, disable the non-SSL port.

Unless explicitly required, consider disabling the non-SSL port.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [when should I enable the non-SSL port for connecting to Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-faq#when-should-i-enable-the-non-ssl-port-for-connecting-to-redis)
- [How to configure Azure Cache for Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-configure#access-ports)
