---
severity: Awareness
pillar: Security
category: Network security and containment
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.FirewallRuleCount/
---

# Review Azure MariaDB server firewall rules

## SYNOPSIS

Determine if there is an excessive number of firewall rules.

## DESCRIPTION

Typically the number of firewall rules required is minimal, with management connectivity from on-premises and cloud application connectivity.

Server-level firewall rules apply to all databases on the Azure Database for MariaDB server.

## RECOMMENDATION

Review Azure for MariaDB server firewall rules.

## LINKS

- [Network security and containment](https://learn.microsoft.com/azure/architecture/framework/security/design-network)
- [Azure Database for MariaDB server firewall rules](https://learn.microsoft.com/azure/mariadb/concepts-firewall-rules)
- [Create and manage Azure Database for MariaDB firewall rules by using the Azure portal](https://learn.microsoft.com/azure/mariadb/howto-manage-firewall-portal)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers/firewallrules)
