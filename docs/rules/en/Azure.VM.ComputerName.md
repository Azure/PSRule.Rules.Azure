---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.ComputerName.md
---

# Use valid VM computer names

## SYNOPSIS

Virtual Machine (VM) computer name should meet naming requirements.

## DESCRIPTION

When configuring Azure VMs the assigned computer name must meet operation system (OS) requirements.

The requirements for Windows VMs are:

- Between 1 and 15 characters long.
- Alphanumerics, and hyphens.
- Can not include only numbers.

The requirements for Linux VMs are:

- Between 1 and 64 characters long.
- Alphanumerics, periods, and hyphens.
- Start with alphanumeric.

## RECOMMENDATION

Consider using computer names that meet OS naming requirements.
Additionally, consider using computer names that match the VM resource name.

## NOTES

VM resource names have different naming restrictions.
See `Azure.VM.Name` for details.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
