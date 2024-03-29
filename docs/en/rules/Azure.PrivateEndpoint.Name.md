---
reviewed: 2021/11/27
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Private Endpoint
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PrivateEndpoint.Name/
---

# Use valid Private Endpoint names

## SYNOPSIS

Private Endpoint names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Private Endpoint names are:

- Between 2 and 64 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Private Endpoint names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Private Endpoint naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Private Endpoint names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/privateendpoints)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
