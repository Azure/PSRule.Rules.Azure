---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.Name/
---

# Use valid Key Vault names

## SYNOPSIS

Key Vault names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Key Vault names are:

- Between 3 and 24 characters long.
- Alphanumerics and hyphens (dash).
- Start with a letter.
- End with a letter or digit.
- Can not contain consecutive hyphens.
- Key Vault names must be globally unique.

## RECOMMENDATION

Consider using names that meet Key Vault naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Key Vault names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)
- [Tagging and resource naming](https://learn.microsoft.com/azure/architecture/framework/devops/app-design#tagging-and-resource-naming)
