---
severity: Critical
pillar: Security
category: Identity and access management
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.AAD.md
---

# Use AAD authentication with SQL databases

## SYNOPSIS

Use Azure Active Directory (AAD) authentication with Azure SQL databases.

## DESCRIPTION

Azure SQL Database offer two authentication models, Azure Active Directory (AAD) and SQL logins.
AAD authentication provides additional features over SQL logins that improve authentication security.

When using AAD authentication, Azure Multi-Factor Authentication (MFA) and Conditional Access are available.

## RECOMMENDATION

Consider using Azure Active Directory (AAD) authentication with SQL databases.

## LINKS

- [Configure and manage Azure Active Directory authentication with SQL](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-aad-authentication-configure)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/2014-04-01/servers/administrators)
- [Using Multi-factor AAD authentication with Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-ssms-mfa-authentication)
- [Conditional Access (MFA) with Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-conditional-access)
