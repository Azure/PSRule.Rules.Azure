---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.AccountName/
---

# Use valid Cosmos DB account names

## SYNOPSIS

Cosmos DB account names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Cosmos DB account names are:

- Between 3 and 44 characters long.
- Lowercase letters, numbers, and hyphens.
- Start and end with letters and numbers.
- Cosmos DB account names must be globally unique.

## RECOMMENDATION

Consider using names that meet Cosmos DB account naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Cosmos DB account names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdocumentdb)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
