---
severity: Awareness
pillar: Security
category: SE:06 Network controls
resource: SQL Database
resourceType: Microsoft.Sql/servers,Microsoft.Sql/servers/firewallRules
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.FirewallRuleCount/
ms-content-id: b877a8ba-bc56-4bfe-9674-4b52b75cd13b
---

# Cleanup SQL logical server firewall rules

## SYNOPSIS

Determine if there is an excessive number of firewall rules.

## DESCRIPTION

Typically the number of firewall rules required is minimal, with management connectivity from on-premises and cloud application connectivity the most common.

## RECOMMENDATION

The logical SQL Server has greater then ten (10) firewall rules.
Some rules may not be needed.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Azure SQL Database and Azure Synapse IP firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql)
- [Create and manage IP firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql#create-and-manage-ip-firewall-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/firewallrules)
