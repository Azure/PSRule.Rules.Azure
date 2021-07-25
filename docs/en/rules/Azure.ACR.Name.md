---
severity: Awareness
pillar: Operational Excellence
category: Repeatable Infrastructure
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Name/
---

# Use valid registry names

## SYNOPSIS

Container registry names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for container registry names are:

- Between 5 and 50 characters long.
- Alphanumerics.
- Container registry names must be globally unique.

## RECOMMENDATION

Consider using names that meet container registry naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if container registry names are unique.

## LINKS

- [Repeatable Infrastructure](https://docs.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
