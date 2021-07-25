---
severity: Awareness
pillar: Operational Excellence
category: Repeatable Infrastructure
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.Name/
---

# Use valid NSG names

## SYNOPSIS

Network Security Group (NSG) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Network Security Group names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- NSG names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Network Security Group naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Network Security Group names are unique.

## LINKS

- [Repeatable Infrastructure](https://docs.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)
