---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.Name/
---

# Use valid VNET names

## SYNOPSIS

Virtual Network (VNET) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Virtual Network names are:

- Between 2 and 64 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- VNET names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Virtual Network naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Virtual Network names are unique.

## LINKS

- [Repeatable infrastructure](https://docs.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
