---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Name/
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

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
