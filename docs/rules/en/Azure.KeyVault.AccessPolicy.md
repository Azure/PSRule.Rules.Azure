---
severity: Important
pillar: Security
category: Identity and access management
resource: Key Vault
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.KeyVault.AccessPolicy.md
---

# Limit access to Key Vault data

## SYNOPSIS

Use the principal of least privilege when assigning access to Key Vault.

## DESCRIPTION

Key Vault is a service designed to securely store sensitive items such as secrets, keys and certificates.
Access Policies determine the permissions user accounts, groups or applications have to Key Vaults items.

The ability for applications and administrators to get, set and list within a Key Vault is commonly required.
However should only be assigned to security principals that require access.
The purge permission should be rarely assigned.

## RECOMMENDATION

Consider assigning access to Key Vault data based on the principle of least privilege.

## LINKS

- [Security recommendations for Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/security-recommendations)
