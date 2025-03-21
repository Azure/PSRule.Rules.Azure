---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Bastion
resourceType: Microsoft.Network/bastionHosts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Bastion.Name/
---

# Use valid names

## SYNOPSIS

Bastion hosts should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Bastion host names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods and hyphens.
- Start with alphanumeric.
- End with alphanumeric or underscore.

## RECOMMENDATION

Consider using names that meet Bastion host naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Bastion host names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Bastion host](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/bastionhosts)
