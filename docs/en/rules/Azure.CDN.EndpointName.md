---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Content Delivery Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.EndpointName/
---

# Use valid CDN endpoint names

## SYNOPSIS

Azure CDN Endpoint names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for CDN endpoint names are:

- Between 1 and 50 characters long.
- Alphanumerics and hyphens.
- Start and end with a letter or number.
- CDN endpoint names must be globally unique.

## RECOMMENDATION

Consider using names that meet CDN endpoint naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if CDN endpoint names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftcdn)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/endpoints)
