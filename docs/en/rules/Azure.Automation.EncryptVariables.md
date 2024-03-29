---
severity: Important
pillar: Security
category: Data protection
resource: Automation Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Automation.EncryptVariables/
ms-content-id: 3c74b891-bf52-44a8-8b71-f7219f83c2ce
---

# Encrypt automation variables

## SYNOPSIS

Azure Automation variables should be encrypted.

## DESCRIPTION

Azure Automation allows configuration properties to be saved as variables.
Variables are a key/ value pairs, which may contain sensitive information.

When variables are encrypted they can only be access from within the runbook context.
Variables not encrypted are visible to anyone with read permissions.

## RECOMMENDATION

Consider encrypting all automation account variables.

Additionally consider, using Key Vault to store secrets.
Key Vault improves security by tightly controlling access to secrets and improving management controls.

## LINKS

- [Variable assets in Azure Automation](https://learn.microsoft.com/azure/automation/shared-resources/variables)
