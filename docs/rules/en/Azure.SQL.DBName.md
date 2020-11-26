---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.DBName.md
---

# Use valid SQL Database names

## SYNOPSIS

Azure SQL Database names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for SQL Database names are:

- Between 1 and 128 characters long.
- Letters, numbers, and special characters except: `<>*%&:\/?`
- Can't end with period or a space.
- Azure SQL Database names must be unique for each logical server.

The following reserved database names can not be used:

- `master`
- `model`
- `tempdb`

## RECOMMENDATION

Consider using names that meet Azure SQL Database naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure SQL Database names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql)
