---
reviewed: 2021/11/27
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Firewall
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Firewall.PolicyName/
---

# Use valid Firewall policy names

## SYNOPSIS

Firewall policy names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Firewall policy names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Firewall policy names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Firewall policy naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Firewall policy names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/firewallpolicies)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
