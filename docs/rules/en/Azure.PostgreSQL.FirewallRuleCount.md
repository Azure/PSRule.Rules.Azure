---
severity: Awareness
pillar: Security
category: Network security and containment
resource: Azure Database for PostgreSQL
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.PostgreSQL.FirewallRuleCount.md
ms-content-id: 7113d8e6-5629-4505-a19b-9c1ff9e17a3b
---

# Cleanup PostgreSQL server firewall rules

## SYNOPSIS

Determine if there is an excessive number of firewall rules.

## DESCRIPTION

Typically the number of firewall rules required is minimal, with management connectivity from on-premises and cloud application connectivity the most common.

## RECOMMENDATION

The PostgreSQL server has greater then ten (10) firewall rules.
Some rules may not be needed.

## LINKS

- [Firewall rules in Azure Database for PostgreSQL - Single Server](https://docs.microsoft.com/en-us/azure/postgresql/concepts-firewall-rules)
- [Create and manage firewall rules for Azure Database for PostgreSQL - Single Server using the Azure portal](https://docs.microsoft.com/azure/postgresql/howto-manage-firewall-using-portal)
