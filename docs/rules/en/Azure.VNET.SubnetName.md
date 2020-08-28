---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Virtual Network
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VNET.SubnetName.md
---

# Use valid subnet names

## SYNOPSIS

Subnet names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Route table names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Subnet names must be unique within a virtual network.

## RECOMMENDATION

Consider using names that meet subnet naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if subnet names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
