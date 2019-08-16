---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.PostgreSQL.UseSSL.md
ms-content-id: 80d34e65-8ab5-4cf3-a0dd-3b5e56e06f40
---

# Azure.PostgreSQL.UseSSL

## SYNOPSIS

Enforce encrypted PostgreSQL connections.

## DESCRIPTION

Azure Database for PostgreSQL is configured to accept unencrypted connections. Unencrypted connections are disabled by default.

Unencrypted communication to PostgreSQL server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for PostgreSQL should be configured to only accept encrypted connections.

When enforce SSL connections is disabled, encrypted and unencrypted connections are permitted. To prevent unencrypted connections, enable SSL connection enforcement.

Unless explicitly required, consider enabling SSL connection enforcement.

For more information see [Configure SSL connectivity in Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/concepts-ssl-connection-security)
