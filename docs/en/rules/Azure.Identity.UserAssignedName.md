---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: User Assigned Managed Identity
resourceType: Microsoft.ManagedIdentity/userAssignedIdentities
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Identity.UserAssignedName/
---

# Use valid Managed Identity names

## SYNOPSIS

Managed Identity names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Managed Identity names are:

- Between 3 and 128 characters long.
- Letters, numbers, underscores, and hyphens.
- Start with letters and numbers.
- Managed Identity names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Managed Identity naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Managed Identity names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftmanagedidentity)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.managedidentity/userassignedidentities)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
