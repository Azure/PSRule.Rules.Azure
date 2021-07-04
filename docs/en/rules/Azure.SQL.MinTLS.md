---
severity: Critical
pillar: Security
category: Encryption
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.MinTLS/
---

# Azure SQL DB server minimum TLS version

## SYNOPSIS

Azure SQL Database servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure SQL Database servers accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Minimal TLS Version](https://docs.microsoft.com/azure/azure-sql/database/connectivity-settings#minimal-tls-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers#ServerProperties)
