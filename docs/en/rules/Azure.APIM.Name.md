---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Name/
---

# Use valid API Management service names

## SYNOPSIS

API Management service names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for API Management service names are:

- Between 1 and 50 characters long.
- Alphanumerics and hyphens.
- Start with letter.
- End with letter or number.
- API Management service names must be globally unique.

## RECOMMENDATION

Consider using names that meet API Management naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if API Management service names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
