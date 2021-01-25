---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.ASMinMembers.md
ms-content-id: 0e9b75e5-2a63-4bea-afeb-2807e6f9d5a0
---

# Use availability sets with at least two members

## SYNOPSIS

Availability sets should be deployed with at least two members.

## DESCRIPTION

An availability set is a logical grouping of VMs that allows Azure to understand how your application is built to provide for redundancy and availability.
Deploy two or more VMs within an availability set to provide for a highly available application.
There is no cost for the Availability Set itself, you only pay for each VM instance that you create.

## RECOMMENDATION

Consider deploying at least two VMs within an availability set to gain availability benefits.

## LINKS

- [Availability options for virtual machines in Azure](https://docs.microsoft.com/azure/virtual-machines/availability)
- [Configure multiple virtual machines in an availability set for redundancy](https://docs.microsoft.com/azure/virtual-machines/manage-availability)
- [Failure mode analysis](https://docs.microsoft.com/azure/architecture/resiliency/failure-mode-analysis#virtual-machine)
- [Tutorial: Create and deploy highly available virtual machines with Azure PowerShell](https://docs.microsoft.com/azure/virtual-machines/windows/tutorial-availability-sets)
- [Reliability checklist](https://docs.microsoft.com/azure/architecture/checklist/resiliency-per-service#virtual-machines)
