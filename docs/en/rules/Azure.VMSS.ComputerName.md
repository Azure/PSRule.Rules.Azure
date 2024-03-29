---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.ComputerName/
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

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
