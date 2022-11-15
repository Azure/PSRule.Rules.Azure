---
severity: Critical
pillar: Security
category: Data protection
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.UseSSL/
---

# Encrypted connections

## SYNOPSIS

Azure Database for MariaDB should only accept encrypted connections.

## DESCRIPTION

Azure Database for MariaDB is configured to only accept encrypted connections by default.
When the setting _enforce SSL connections_ is disabled, encrypted and unencrypted connections are permitted.
This does not indicate that unencrypted connections are being used.

Unencrypted communication to MariaDB server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for MariaDB should be configured to only accept encrypted connections.
Unless explicitly required, consider enabling _enforce SSL connections_.

Also consider using Azure Policy to audit or enforce this configuration.

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [SSL connectivity in Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/concepts-ssl-connection-security)
