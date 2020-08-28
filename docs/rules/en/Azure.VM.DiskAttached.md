---
severity: Important
pillar: Cost Optimization
category: Resource usage
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.DiskAttached.md
ms-content-id: 23a06a0e-7965-4d43-8e29-bb9ac6eeffcc
---

# Remove unused managed disks

## SYNOPSIS

Managed disks should be attached to virtual machines or removed.

## DESCRIPTION

Unattached managed disks are charged but not in use.
Unattached managed disks still consume storage and are charged on their size.

## RECOMMENDATION

Consider removing managed disks that are no longer required to reduce complexity and costs.

## LINKS

- [Managed Disk pricing](https://azure.microsoft.com/pricing/details/managed-disks/)
