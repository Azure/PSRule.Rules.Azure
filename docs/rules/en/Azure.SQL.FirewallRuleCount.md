---
severity: Awareness
pillar: Security
category: Network security and containment
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.FirewallRuleCount.md
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

- [Azure SQL Database and Azure Synapse IP firewall rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure)
- [Create and manage IP firewall rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure#create-and-manage-ip-firewall-rules)
