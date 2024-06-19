---
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.FirewallIPRange/
---

# Review Azure MariaDB server firewall permitted public IP addresses

## SYNOPSIS

Determine if there is an excessive number of permitted IP addresses.

## DESCRIPTION

Typically the number of IP address rules permitted through the firewall is minimal, with management connectivity from on-premises and cloud application connectivity.

Server-level firewall permitted IP addresses apply to all databases on the Azure Database for MariaDB server.

## RECOMMENDATION

Review the number of Azure for MariaDB server firewall permitted public IP addresses configured.
Consider to removing IP addresses that are no longer needed.

## NOTES

This rule fails when the number of configured public IP addresses exceeds ten (10).

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Azure Database for MariaDB server firewall rules](https://learn.microsoft.com/azure/mariadb/concepts-firewall-rules)
- [Create and manage Azure Database for MariaDB firewall rules by using the Azure portal](https://learn.microsoft.com/azure/mariadb/howto-manage-firewall-portal)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers/firewallrules)
