---
reviewed: 2023-07-09
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Virtual WAN
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.vWAN.Name/
---

# Use valid vWAN names

## SYNOPSIS

Virtual WAN (vWAN) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for vWAN names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- vWAN names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Virtual WAN (vWAN) naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if vWAN names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualwans)
