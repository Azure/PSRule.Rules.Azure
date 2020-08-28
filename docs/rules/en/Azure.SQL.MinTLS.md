---
severity: Critical
pillar: Security
category: Encryption
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.MinTLS.md
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

- [Minimal TLS Version](https://docs.microsoft.com/en-gb/azure/azure-sql/database/connectivity-settings#minimal-tls-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/en-us/updates/azuretls12/)
- [Azure template reference](https://docs.microsoft.com/en-gb/azure/templates/microsoft.sql/servers#ServerProperties)
