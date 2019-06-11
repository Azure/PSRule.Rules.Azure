---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Redis.NonSslPort.md
---

# Azure.Redis.NonSslPort

## SYNOPSIS

Redis Cache should only accept secure connections.

## DESCRIPTION

Azure Redis Cache is configured to accept unencrypted connections using a non-SSL port. Unencrypted connections are disabled by default.

Unencrypted communication to Redis Cache could allow disclosure of information to an untrusted party.

This does not indicate that unencrypted connections are being used.

## RECOMMENDATION

Azure Redis Cache should be configured to only accept secure connections.

When the non-SSL port is enabled, encrypted and unencrypted connections are permitted. To prevent unencrypted connections, disable the non-SSL port.

Unless explicitly required, consider disabling the non-SSL port.

For more information see [when should I enable the non-SSL port for connecting to Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-faq#when-should-i-enable-the-non-ssl-port-for-connecting-to-redis) and [How to configure Azure Cache for Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-configure#access-ports)
