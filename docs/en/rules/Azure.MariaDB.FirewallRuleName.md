---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Azure Database for MariaDB
resourceType: Microsoft.DBforMariaDB/servers,Microsoft.DBforMariaDB/servers/firewallRules
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.FirewallRuleName/
---

# Use valid firewall rule names

## SYNOPSIS

Azure Database for MariaDB firewall rules should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Azure Database for MariaDB firewall rule names are:

- Between 1 and 128 characters long.
- Alphanumerics, hyphens, and underscores.

## RECOMMENDATION

Consider using names that meet Azure Database for MariaDB firewall rule naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure Database for MariaDB firewall rule names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions Azure Database for MariaDB resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers/firewallrules)
