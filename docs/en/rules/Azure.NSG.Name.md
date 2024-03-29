---
reviewed: 2021/11/27
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.Name/
---

# Use valid NSG names

## SYNOPSIS

Network Security Group (NSG) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for NSG names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- NSG names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Network Security Group naming requirements.
Additionally consider naming resources with a standard naming convention.
If creating resources using CI/CD pipelines consider programmatically Generating Cloud Resource Names using
[PowerShell](https://blog.tyang.org/2022/09/10/programmatically-generate-cloud-resource-names-part-1/) or
[Bicep](https://4bes.nl/2021/10/10/get-a-consistent-azure-naming-convention-with-bicep-modules/)

## NOTES

This rule does not check if NSG names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networksecuritygroups)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
