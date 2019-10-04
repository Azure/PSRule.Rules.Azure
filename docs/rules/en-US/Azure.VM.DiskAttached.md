---
severity: Awareness
category: Cost management
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VM.DiskAttached.md
ms-content-id: 23a06a0e-7965-4d43-8e29-bb9ac6eeffcc
---

# Unattached managed disks

## SYNOPSIS

Managed disks should be attached to virtual machines.

## DESCRIPTION

Unattached managed disks are charged but not in use. Unattached managed disks still consume storage and are charged on their size.

## RECOMMENDATION

Consider removing managed disks are no longer required to reduce complexity and storage costs.

For more information see [Managed Disk pricing](https://azure.microsoft.com/en-us/pricing/details/managed-disks/).
