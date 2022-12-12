---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.Name/
---

# Use valid names

## SYNOPSIS

Application Gateways should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Application Gateway names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods and hyphens.
- Start with alphanumeric.
- End with alphanumeric or underscore.

## RECOMMENDATION

Consider using names that meet Application Gateway naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Application Gateways names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Application Gateway](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)
