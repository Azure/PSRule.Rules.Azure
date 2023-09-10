---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.Name/
---

# Use valid Public IP names

## SYNOPSIS

Public IP names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Public IP names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Public IP names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Public IP naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Public IP names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/well-architected/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses)
