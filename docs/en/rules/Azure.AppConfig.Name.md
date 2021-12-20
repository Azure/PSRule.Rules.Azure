---
reviewed: 2021/12/20
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.Name/
---

# Use valid App Configuration store names

## SYNOPSIS

App Configuration store names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for App Configuration store names are:

- Between 5 and 50 characters long.
- Alphanumerics and hyphens.
- Start and end with a letter or number.
- App Configuration store names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet App Configuration store naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if App Configuration store names are unique.

## LINKS

- [Repeatable infrastructure](https://docs.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftappconfiguration)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
