---
severity: Important
pillar: Security
category: Encryption
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.APIM.EncryptValues.md
---

# Use encrypted named values

## SYNOPSIS

API Management named values should be encrypted.

## DESCRIPTION

API Management allows configuration properties to be saved as named values.
Named values are a key/ value pairs, which may contain sensitive information.

When named values are marked as secret they are masked by default in the portal.

## RECOMMENDATION

Consider encrypting all API Management named values.

Additionally consider, using Key Vault to store secrets.
Key Vault improves security by tightly controlling access to secrets and improving management controls.

## LINKS

- [Manage secrets using properties](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-properties)
