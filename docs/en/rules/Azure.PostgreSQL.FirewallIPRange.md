---
severity: Important
pillar: Security
category: Network security and containment
resource: Azure Database for PostgreSQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.FirewallIPRange/
ms-content-id: fc3b5764-5b4a-4915-9311-75ec6a0d0d55
---

# Limit PostgreSQL server firewall rule range

## SYNOPSIS

Determine if there is an excessive number of permitted IP addresses.

## DESCRIPTION

Typically the number of IP address rules permitted through the firewall is minimal, with management connectivity from on-premises and cloud application connectivity the most common.

## RECOMMENDATION

The PostgreSQL server has greater then ten (10) public IP addresses that are permitted network access. Some rules may not be needed or can be reduced.

## LINKS

- [Firewall rules in Azure Database for PostgreSQL - Single Server](https://learn.microsoft.com/azure/postgresql/concepts-firewall-rules)
- [Create and manage firewall rules for Azure Database for PostgreSQL - Single Server using the Azure portal](https://learn.microsoft.com/azure/postgresql/howto-manage-firewall-using-portal)
