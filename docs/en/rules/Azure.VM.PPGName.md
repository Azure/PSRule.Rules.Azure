---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.PPGName/
---

# Use valid PPG names

## SYNOPSIS

Proximity Placement Group (PPG) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for placement groups names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start and end with alphanumeric.
- PPG names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Proximity Placement Group naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Proximity Placement Group names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
