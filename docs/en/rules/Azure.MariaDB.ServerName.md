---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.ServerName/
---

# Use valid server names

## SYNOPSIS

Azure Database for MariaDB servers should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Azure Database for MariaDB server names are:

- Between 3 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- MariaDB server names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure Database for MariaDB server naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure Database for MariaDB server names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions Azure Database for MariaDB resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers)
