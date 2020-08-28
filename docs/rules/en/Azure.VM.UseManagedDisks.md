---
severity: Important
pillar: Reliability
category: Availability
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.UseManagedDisks.md
---

# Use Managed Disks

## SYNOPSIS

Virtual machines (VMs) should use managed disks.

## DESCRIPTION

VMs can be configured with un-managed or managed disks.
Un-managed disks, are `.vhd` files stored on a Storage Account that you manage as files.
Managed disks allow you to managed the VM disk and the Storage Account is managed by Microsoft.

Managed disks are the successor to un-managed disks and provide an number of additional features.
Using managed disks reduces management of VM storage, improves durability and availability of VMs.

## RECOMMENDATION

Consider using managed disks for virtual machine storage.

## LINKS

- [Introduction to Azure managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview)
