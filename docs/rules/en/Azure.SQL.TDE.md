---
severity: Critical
pillar: Security
category: Encryption
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.TDE.md
---

# Use SQL database TDE

## SYNOPSIS

Use Transparent Data Encryption (TDE) with Azure SQL Database.

## DESCRIPTION

TDE helps protect Azure SQL Databases against malicious offline access by encrypting data at rest.
SQL Databases perform real-time encryption and decryption of the database, backups, and log files.
Encryption is perform at rest without requiring changes to the application.

## RECOMMENDATION

Consider enable Transparent Data Encryption (TDE) for Azure SQL Databases to perform encryption at rest.

## LINKS

- [Transparent data encryption for SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/transparent-data-encryption-azure-sql)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/2014-04-01/servers/databases/transparentdataencryption)
