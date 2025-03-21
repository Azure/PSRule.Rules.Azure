---
reviewed: 2021-12-20
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Application Insights
resourceType: Microsoft.Insights/components
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppInsights.Name/
---

# Use valid Application Insights resource names

## SYNOPSIS

Azure Application Insights resources names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Application Insights resource names are:

- Between 1 and 255 characters long.
- Letters, numbers, hyphens, periods, underscores, and parenthesis.
- Must not end in a period.
- Resource names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Application Insights resource naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Application Insights resource names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/components)
