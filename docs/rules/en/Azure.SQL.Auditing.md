---
severity: Important
pillar: Security
category: Security operations
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.Auditing.md
ms-content-id: d6084913-9ff9-40b6-a65b-30fcd4d49251
---

# Enable auditing for Azure SQL DB server

## SYNOPSIS

Enable auditing for Azure SQL logical server.

## DESCRIPTION

Auditing for Azure SQL Database tracks database events and writes them to an audit log.
Audit logs help you find suspicious events, unusual activity, and trends.

## RECOMMENDATION

Consider enabling auditing for each SQL Database logical server and review reports on a regular basis.

## LINKS

- [Auditing for Azure SQL Database and Azure Synapse Analytics](https://docs.microsoft.com/azure/azure-sql/database/auditing-overview)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers/auditingsettings)
