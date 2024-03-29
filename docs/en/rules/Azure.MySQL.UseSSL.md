---
severity: Critical
pillar: Security
category: Data protection
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.UseSSL/
ms-content-id: 2569c452-b0d4-45ca-a6df-72ff7e911be3
---

# Enforce encrypted MySQL connections

## SYNOPSIS

Enforce encrypted MySQL connections.

## DESCRIPTION

Azure Database for MySQL is configured to only accept encrypted connections by default.
When the setting _enforce SSL connections_ is disabled, encrypted and unencrypted connections are permitted.
This does not indicate that unencrypted connections are being used.

Unencrypted communication to MySQL server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for MySQL should be configured to only accept encrypted connections.
Unless explicitly required, consider enabling _enforce SSL connections_.

Also consider using Azure Policy to audit or enforce this configuration.

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [SSL connectivity in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/concepts-ssl-connection-security)
