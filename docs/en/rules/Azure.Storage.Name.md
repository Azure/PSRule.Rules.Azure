---
reviewed: 2023-12-01
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.Name/
---

# Use valid storage account names

## SYNOPSIS

Storage Account names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Storage Account names are:

- Between 3 and 24 characters long.
- Lowercase letters or numbers.
- Storage Account names must be globally unique.

## RECOMMENDATION

Consider using names that meet Storage Account naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Storage Account names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
