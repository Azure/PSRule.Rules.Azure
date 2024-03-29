---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: SQL Managed Instance
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.Name/
---

# Use valid SQL Managed Instance names

## SYNOPSIS

SQL Managed Instance names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for SQL Managed Instance names are:

- Between 1 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- SQL Managed Instance names must be globally unique.

## RECOMMENDATION

Consider using names that meet SQL Managed Instance naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if SQL Managed Instance names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql)
