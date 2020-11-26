---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Azure Database for MySQL
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.MySQL.ServerName.md
---

# Use valid MySQL DB server names

## SYNOPSIS

Azure MySQL DB server names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for MySQL DB server names are:

- Between 3 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- MySQL DB server names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure MySQL DB server naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure MySQL DB server names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformysql)
