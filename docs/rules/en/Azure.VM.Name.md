---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.Name.md
---

# Use valid VM names

## SYNOPSIS

Virtual Machine (VM) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for VM names are:

- Between 1 and 64 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- VM names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet VM resource name requirements.
Additionally, consider using a resource name that meeting OS naming requirements.

## NOTES

This rule does not check if VM names are unique.
Additionally, VM computer names have additional restrictions.
See `Azure.VM.ComputerName` for details.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
