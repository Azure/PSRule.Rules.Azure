---
severity: Critical
pillar: Security
category: Encryption
resource: Azure Database for PostgreSQL
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.PostgreSQL.UseSSL.md
ms-content-id: 80d34e65-8ab5-4cf3-a0dd-3b5e56e06f40
---

# Enforce encrypted PostgreSQL connections

## SYNOPSIS

Enforce encrypted PostgreSQL connections.

## DESCRIPTION

Azure Database for PostgreSQL is configured to only accept encrypted connections by default.
When the setting _enforce SSL connections_ is disabled, encrypted and unencrypted connections are permitted.
This does not indicate that unencrypted connections are being used.

Unencrypted communication to PostgreSQL server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for PostgreSQL should be configured to only accept encrypted connections.
Unless explicitly required, consider enabling _enforce SSL connections_.

Also consider using Azure Policy to audit or enforce this configuration.

## LINKS

- [Configure SSL connectivity in Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/concepts-ssl-connection-security)
