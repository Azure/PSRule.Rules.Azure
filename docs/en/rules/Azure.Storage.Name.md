---
severity: Awareness
pillar: Operational Excellence
category: Repeatable Infrastructure
resource: Storage Account
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

- [Repeatable Infrastructure](https://docs.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
