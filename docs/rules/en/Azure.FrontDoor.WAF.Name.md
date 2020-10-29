---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.WAF.Name.md
---

# Use valid Front Door WAF policy names

## SYNOPSIS

Front Door WAF policy names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Front Door Web Application Firewall (WAF) policy names are:

- Between 1 and 128 characters long.
- Letters or numbers.
- Start with a letter.
- Unique within a resource group.

## RECOMMENDATION

Consider using names that meet Front Door WAF policy naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Front Door WAF policy names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies)
- [Tagging and resource naming](https://docs.microsoft.com/azure/architecture/framework/devops/app-design#tagging-and-resource-naming)
