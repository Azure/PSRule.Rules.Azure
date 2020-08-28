---
severity: Important
pillar: Reliability
category: Availability
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.Standalone.md
---

# Azure.VirtualMachine.Standalone

## SYNOPSIS

VMs must use premium disks or use availability sets/ zones to meet SLA requirements.

## DESCRIPTION

VMs must use premium disks or use availability sets/ zones to meet SLA requirements.

## RECOMMENDATION

Consider using availability sets/ zones or only premium/ ultra disks to improve SLA.

## LINKS

- [Virtual Machine SLA](https://azure.microsoft.com/en-au/support/legal/sla/virtual-machines)
- [Availability options for virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/availability)
- [Manage the availability of Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability)
- [Manage the availability of Linux virtual machines](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/manage-availability)
