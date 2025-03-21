---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: SignalR Service
resourceType: Microsoft.SignalRService/SignalR
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SignalR.Name/
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

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.signalrservice/signalr)
