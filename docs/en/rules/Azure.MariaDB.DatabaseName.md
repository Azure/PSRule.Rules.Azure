---
reviewed: 2023-07-22
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.DatabaseName/
---

# Use valid database names

## SYNOPSIS

Azure Database for MariaDB databases should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Azure Database for MariaDB database names are:

- Between 1 and 63 characters long.
- Alphanumerics and hyphens.

## RECOMMENDATION

Consider using names that meet Azure Database for MariaDB database naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure Database for MariaDB database names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions Azure Database for MariaDB resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Resource naming and tagging decision guide](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming-and-tagging-decision-guide)
- [Abbreviation examples for Azure resources](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers/databases)
