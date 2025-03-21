---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Recovery Services Vault
resourceType: Microsoft.RecoveryServices/vaults
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RSV.Name/
---

# Use valid names

## SYNOPSIS

Recovery Services vaults should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Recovery Services vault names are:

- Between 2 and 50 characters long.
- Alphanumerics and hyphens.
- Start with letter.

## RECOMMENDATION

Consider using names that meet Recovery Services vault naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Recovery Services vault names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Recovery Services vault](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftrecoveryservices)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.recoveryservices/vaults)
