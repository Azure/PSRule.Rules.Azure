---
severity: Awareness
pillar: Cost Optimization
category: Resource usage
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.DiskSizeAlignment.md
---

# Allocate VM disks aligned to billing model

## SYNOPSIS

Align to the Managed Disk billing model to improve cost efficiency.

## DESCRIPTION

Managed disk is smaller than SKU size.

## RECOMMENDATION

Consider resizing or optimizing storage to reduce waste by using disk sizes that align to the billing model for Managed Disks.
Also consider, sizing and striping disks to optimize performance.

## LINKS

- [Managed Disks pricing](https://azure.microsoft.com/pricing/details/managed-disks/)
