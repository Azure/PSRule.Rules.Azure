---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.KeyName/
---

# Use valid Key Vault Key names

## SYNOPSIS

Key Vault Key names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Key Vault Key names are:

- Between 1 and 127 characters long.
- Alphanumerics and hyphens (dash).
- Keys must be unique within a Key Vault.

## RECOMMENDATION

Consider using key names that meet Key Vault naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Key names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults/secrets)
- [Tagging and resource naming](https://learn.microsoft.com/azure/architecture/framework/devops/app-design#tagging-and-resource-naming)
