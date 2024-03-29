---
severity: Awareness
pillar: Security
category: Network security and containment
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.FirewallRuleCount/
ms-content-id: 9debdffb-0da1-4b8d-8a17-3f480f1015ec
---

# Cleanup MySQL server firewall rules

## SYNOPSIS

Determine if there is an excessive number of firewall rules.

## DESCRIPTION

Typically the number of firewall rules required is minimal, with management connectivity from on-premises and cloud application connectivity the most common.

## RECOMMENDATION

The MySQL server has greater then ten (10) firewall rules.
Some rules may not be needed.

## LINKS

- [Create and manage Azure Database for MySQL firewall rules by using the Azure portal](https://learn.microsoft.com/azure/mysql/howto-manage-firewall-using-portal)
- [Create and manage Azure Database for MySQL VNet service endpoints and VNet rules by using the Azure portal](https://learn.microsoft.com/azure/mysql/howto-manage-vnet-using-portal)
