---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Resource Group
resourceType: Microsoft.Resources/resourceGroups
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ResourceGroup.Name/
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

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
