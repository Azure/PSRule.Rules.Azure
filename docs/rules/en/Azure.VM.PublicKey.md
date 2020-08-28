---
severity: Important
pillar: Security
category: Identity and access management
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.PublicKey.md
---

# Use public keys for Linux

## SYNOPSIS

Linux virtual machines should use public keys.

## DESCRIPTION

Linux virtual machines support either password or public key based authentication for the default administrator account.

## RECOMMENDATION

Consider using public key based authentication instead of passwords.
