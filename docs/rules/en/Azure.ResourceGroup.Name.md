---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Resource Group
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ResourceGroup.Name.md
---

# Use valid resource group names

## SYNOPSIS

Resource Group names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Resource Group names are:

- Between 1 and 90 characters long.
- Alphanumerics, underscores, parentheses, hyphens, periods.
- Can't end with period.
- Resource Group names must be unique within a subscription.

## RECOMMENDATION

Consider using names that meet Resource Group naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Resource Group names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
