---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Azure Database for PostgreSQL
resourceType: Microsoft.DBforPostgreSQL/servers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.ServerName/
---

# Use valid PostgreSQL DB server names

## SYNOPSIS

Azure PostgreSQL DB server names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for PostgreSQL DB server names are:

- Between 3 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- PostgreSQL DB server names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure PostgreSQL DB server naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure PostgreSQL DB server names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/servers)
