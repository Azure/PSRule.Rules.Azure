---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.ASName.md
---

# Use valid Availability Set names

## SYNOPSIS

Availability Set names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Availability Set names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Availability Set names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Availability Set naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Availability Set names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
