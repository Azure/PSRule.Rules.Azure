---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Route table
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Route.Name.md
---

# Use valid Route table names

## SYNOPSIS

Route table names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Route table names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Route table names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Route table naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Route table names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
