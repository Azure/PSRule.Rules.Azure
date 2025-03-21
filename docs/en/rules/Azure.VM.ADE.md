---
severity: Important
pillar: Security
category: Data protection
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ADE/
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

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-at-rest)
- [Creating and configuring a key vault for Azure Disk Encryption](https://learn.microsoft.com/azure/virtual-machines/windows/disk-encryption-key-vault)
- [Azure Disk Encryption scenarios on Windows VMs](https://learn.microsoft.com/azure/virtual-machines/windows/disk-encryption-windows)
