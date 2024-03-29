---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.DiskName/
---

# Use valid Managed Disk names

## SYNOPSIS

Managed Disk names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Managed Disk names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Managed Disk names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Managed Disk naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Managed Disk names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
