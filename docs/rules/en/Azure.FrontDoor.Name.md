---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.Name.md
---

# Use valid Front Door names

## SYNOPSIS

Front Door names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Front Door names are:

- Between 5 and 64 characters long.
- Alphanumerics and hyphens.
- Start and end with alphanumeric.
- Front Door names must be globally unique.

## RECOMMENDATION

Consider using names that meet Front Door naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Front Door names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
