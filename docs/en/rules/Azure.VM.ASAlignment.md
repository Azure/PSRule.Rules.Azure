---
severity: Important
pillar: Reliability
category: Availability
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ASAlignment/
ms-content-id: 28583693-11e4-4a16-b864-8caa6e408162
---

# Use aligned availability sets

## SYNOPSIS

Use availability sets aligned with managed disks fault domains.

## DESCRIPTION

Availability sets can be configured to align with managed disk fault domains.
When aligned, the fault domain for storage is co-located with compute.
Aligned availability sets help prevent compute and storage from a single VM spanning multiple fault domains.

## RECOMMENDATION

Consider deploying VMs with managed disks into aligned availability sets.

## LINKS

- [Availability sets](https://docs.microsoft.com/azure/virtual-machines/availability#availability-sets)
- [Managed disk integration with availability sets](https://docs.microsoft.com/azure/virtual-machines/managed-disks-overview)
- [Reliability checklist](https://docs.microsoft.com/azure/architecture/checklist/resiliency-per-service#virtual-machines)
