---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.MinTLS/
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

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [TLS enforcement in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/concepts-ssl-connection-security#tls-enforcement-in-azure-database-for-mysql)
- [Set TLS configurations for Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/howto-tls-configurations#set-tls-configurations-for-azure-database-for-mysql)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers#ServerPropertiesForCreate)
