---
reviewed: 2021-11-27
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Load Balancer
resourceType: Microsoft.Network/loadBalancers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.Name/
---

# Use valid Load Balancer names

## SYNOPSIS

Load Balancer names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Load Balancer names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Load Balancer names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Load Balancer naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Load Balancer names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
