---
severity: Important
pillar: Security
category: Encryption
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.ADE.md
---

# Use Azure Disk Encryption

## SYNOPSIS

Use Azure Disk Encryption (ADE).

## DESCRIPTION

Virtual machines (VMs) can be encrypted using ADE to protect disks with full disk encryption.
Storage Service Encryption (SSE) is encryption as rest for Managed Disks and Storage Accounts.
SSE automatically decrypts storage as it is read.
Full disk encryption varies from SSE by decrypting disks on read within the operating system.

ADE protects disk decryption keys within Key Vault.

## RECOMMENDATION

Consider using Azure Disk Encryption (ADE) to protect VM disks from being downloaded and accessed offline.

## NOTE

This rule is applicable to exports of exiting resources.
This rule will be skipped when validating Azure template files.

## LINKS

- [Creating and configuring a key vault for Azure Disk Encryption](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-key-vault)
- [Azure Disk Encryption scenarios on Windows VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-windows)
