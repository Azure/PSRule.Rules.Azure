---
severity: Critical
pillar: Security
category: Encryption
resource: Azure Database for MySQL
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.MySQL.MinTLS.md
---

# MySQL DB server minimum TLS version

## SYNOPSIS

MySQL DB servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that MySQL DB servers accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

## LINKS

- [TLS enforcement in Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/concepts-ssl-connection-security#tls-enforcement-in-azure-database-for-mysql)
- [Set TLS configurations for Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/howto-tls-configurations#set-tls-configurations-for-azure-database-for-mysql)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/en-us/updates/azuretls12/)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.dbformysql/servers#ServerPropertiesForCreate)
