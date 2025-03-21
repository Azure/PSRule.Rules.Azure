---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Key Vault
resourceType: Microsoft.KeyVault/vaults,Microsoft.KeyVault/vaults/keys
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

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault)
- [Tagging and resource naming](https://learn.microsoft.com/azure/architecture/framework/devops/app-design#tagging-and-resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults/secrets)
