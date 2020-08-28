---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Load Balancer
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.LB.Name.md
---

# Use valid Load Balancer names

## SYNOPSIS

Load Balancer names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Load Balancer names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Load Balancer names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Load Balancer naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Load Balancer names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
