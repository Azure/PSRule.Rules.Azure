---
reviewed: 2024-03-11
severity: Important
pillar: Cost Optimization
category: CO:07 Component costs
resource: Virtual Machine
resourceType: Microsoft.Compute/disks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.DiskAttached/
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

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [CO:07 Component costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-component-costs)
- [Managed Disk pricing](https://azure.microsoft.com/pricing/details/managed-disks/)
