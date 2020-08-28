---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: SignalR Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SignalR.Name.md
---

# Use valid SignalR service names

## SYNOPSIS

SignalR service instance names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for SignalR service names are:

- Between 3 and 63 characters long.
- Alphanumerics and hyphens.
- Start with letter.
- End with letter or number.
- SignalR service names must be globally unique.

## RECOMMENDATION

Consider using names that meet SignalR service naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if SignalR service names are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
