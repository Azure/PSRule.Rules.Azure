---
reviewed: 2023-07-02
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Cognitive Search
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Search.Name/
---

# Use valid Cognitive Search service names

## SYNOPSIS

Azure Cognitive Search service names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Cognitive Search service names are:

- Between 2 and 60 characters long.
- Lowercase letters, numbers, and hyphens.
- The first two and last one character must be a letter or a number.
- Cognitive Search service names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure Cognitive Search service naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Azure Cognitive Search service names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [REST API reference](https://learn.microsoft.com/rest/api/searchmanagement/2022-09-01/services/create-or-update)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices)
