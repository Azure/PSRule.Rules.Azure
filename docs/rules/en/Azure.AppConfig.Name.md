---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: App Configuration
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppConfig.Name.md
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

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftappconfiguration)
