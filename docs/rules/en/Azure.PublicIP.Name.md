---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Public IP address
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.PublicIP.Name.md
---

# Use valid Public IP names

## SYNOPSIS

Public IP names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Public IP names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Public IP names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Public IP naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Public IP names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
