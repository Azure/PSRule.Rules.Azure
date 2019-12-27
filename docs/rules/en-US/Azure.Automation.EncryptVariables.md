---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Automation.EncryptVariables.md
ms-content-id: 3c74b891-bf52-44a8-8b71-f7219f83c2ce
---

# Azure.AppService.UseHTTPS

## SYNOPSIS

Azure Automation variables should be encrypted

## DESCRIPTION

Azure Automation variables should be encrypted

## RECOMMENDATION

Azure Automation variables should be encrypted - the values within can only be access from within the runbook context. If a more secure option is required consider using an automation credential or Azure Key Vault.
