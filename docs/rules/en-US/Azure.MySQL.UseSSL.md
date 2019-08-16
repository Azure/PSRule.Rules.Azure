---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.MySQL.UseSSL.md
ms-content-id: 2569c452-b0d4-45ca-a6df-72ff7e911be3
---

# Azure.MySQL.UseSSL

## SYNOPSIS

Enforce encrypted MySQL connections.

## DESCRIPTION

Azure Database for MySQL is configured to accept unencrypted connections. Unencrypted connections are disabled by default.

Unencrypted communication to MySQL server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for MySQL should be configured to only accept encrypted connections.

When enforce SSL connections is disabled, encrypted and unencrypted connections are permitted. To prevent unencrypted connections, enable SSL connection enforcement.

Unless explicitly required, consider enabling SSL connection enforcement.

For more information see [SSL connectivity in Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/concepts-ssl-connection-security)
