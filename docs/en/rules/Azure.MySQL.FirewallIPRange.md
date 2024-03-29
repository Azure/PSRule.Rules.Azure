---
severity: Important
pillar: Security
category: Network security and containment
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.FirewallIPRange/
ms-content-id: d8bf9741-541c-4229-86cb-2e2dad32d9a9
---

# Limit MySQL server firewall rule range

## SYNOPSIS

Determine if there is an excessive number of permitted IP addresses.

## DESCRIPTION

Typically the number of IP address rules permitted through the firewall is minimal, with management connectivity from on-premises and cloud application connectivity the most common.

## RECOMMENDATION

The MySQL server has greater then ten (10) public IP addresses that are permitted network access.
Some rules may not be needed or can be reduced.

## LINKS

- [Create and manage Azure Database for MySQL firewall rules by using the Azure portal](https://learn.microsoft.com/azure/mysql/howto-manage-firewall-using-portal)
- [Create and manage Azure Database for MySQL VNet service endpoints and VNet rules by using the Azure portal](https://learn.microsoft.com/azure/mysql/howto-manage-vnet-using-portal)
