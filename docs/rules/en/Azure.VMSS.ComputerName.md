---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Virtual Machine Scale Sets
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VMSS.ComputerName.md
---

# Use valid VMSS computer names

## SYNOPSIS

Virtual Machine Scale Set (VMSS) computer name should meet naming requirements.

## DESCRIPTION

When configuring Azure VMSS the assigned computer name prefix must meet operation system (OS) requirements.

The requirements for Windows VM instances are:

- Between 1 and 15 characters long.
- Alphanumerics, and hyphens.
- Can not include only numbers.

The requirements for Linux VM instances are:

- Between 1 and 64 characters long.
- Alphanumerics, periods, and hyphens.
- Start with alphanumeric.

## RECOMMENDATION

Consider using computer names that meet OS naming requirements.
Additionally, consider using computer names that match the VMSS resource name.

## NOTES

VMSS resource names have different naming restrictions.
See `Azure.VMSS.Name` for details.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
