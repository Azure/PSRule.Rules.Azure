---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Deployment
resourceType: Microsoft.Resources/deployments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.Name/
---

# Use valid nested deployments names

## SYNOPSIS

Nested deployments should meet naming requirements of deployments.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Azure deployments names are:

- Between 1 and 64 characters long.
- Alphanumerics, underscores, parentheses, hyphens, and periods.

## RECOMMENDATION

Consider using nested deployment names thas meets naming requirements of deployments.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if nested deployment names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions deployments resource](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftresources)
- [Using linked and nested templates when deploying Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/templates/linked-templates)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.resources/deployments)
