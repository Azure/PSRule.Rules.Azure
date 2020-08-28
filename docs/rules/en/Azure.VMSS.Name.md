---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Virtual Machine Scale Sets
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VMSS.Name.md
---

# Use valid VMSS names

## SYNOPSIS

Virtual Machine Scale Set (VMSS) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for VMSS names are:

- Between 1 and 64 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- VM names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet VMSS resource name requirements.
Additionally, consider using a resource name that meeting OS naming requirements.

## NOTES

This rule does not check if VMSS names are unique.
Additionally, VMSS computer names have additional restrictions.
See `Azure.VMSS.ComputerName` for details.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
