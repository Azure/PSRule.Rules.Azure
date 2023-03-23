---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.Name/
---

# Use valid container app names

## SYNOPSIS

Container Apps should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for container app names are:

- Between 2 and 32 characters long.
- Lowercase letters, numbers, and hyphens.
- Start with letter and end with alphanumeric.

## RECOMMENDATION

Consider using container app names thas meets naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if container app names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for container app resource](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftapp)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
