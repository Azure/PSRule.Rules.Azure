---
reviewed: 2023-12-01
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks
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

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
