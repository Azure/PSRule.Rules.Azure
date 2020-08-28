---
severity: Important
pillar: Security
category: Security operations
resource: Key Vault
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.KeyVault.Logs.md
---

# Audit Key Vault data access

## SYNOPSIS

Audit and monitor access to Key Vault data.

## DESCRIPTION

To capture access to Key Vault data, diagnostic settings must be configured.
When configuring diagnostics settings enable access logs.

Management operations for Key Vault is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostic settings to log access for Key Vault data.
Also consider, storing the access data into Azure Monitor and using Key Vault Analytics.

## LINKS

- [Azure Key Vault logging](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-logging)
- [Security recommendations for Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/security-recommendations#monitoring)
- [Azure Key Vault Analytics solution in Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/azure-key-vault)
