---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.FGName.md
---

# Use valid SQL failover group names

## SYNOPSIS

Azure SQL failover group names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for SQL failover group names are:

- Between 1 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- SQL failover group names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure SQL failover group naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure SQL failover group names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql)
