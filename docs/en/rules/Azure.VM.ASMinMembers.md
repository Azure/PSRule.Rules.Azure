---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ASMinMembers/
ms-content-id: 0e9b75e5-2a63-4bea-afeb-2807e6f9d5a0
---

# Use availability sets with at least two members

## SYNOPSIS

Availability sets should be deployed with at least two virtual machines (VMs).

## DESCRIPTION

An availability set is a logical grouping of VMs that allows Azure to optimize the placement of VMs.
Azure uses this grouping to separate VMs within the availablity set across fault and update domains.
Each VM in your availability set is assigned an update domain and a fault domain.
VMs in different update and fault domains is mapped to different underlying physical hardware.
The reason for doing this is to improve reliability by removing some single points of failure.

Deploy two or more VMs within an availability set to provide for a highly available application.
There is no cost for the Availability Set itself, you only pay for each VM instance that you create.

## RECOMMENDATION

Consider deploying at least two VMs within an availability set to gain availability benefits.

## NOTES

This rule applies when analyzing resources deployed to Azure (in-flight).

## LINKS

- [Reliability checklist](https://docs.microsoft.com/azure/architecture/checklist/resiliency-per-service#virtual-machines)
- [Availability sets overview](https://docs.microsoft.com/azure/virtual-machines/availability-set-overview)
- [Availability options for virtual machines in Azure](https://docs.microsoft.com/azure/virtual-machines/availability)
- [Failure mode analysis](https://docs.microsoft.com/azure/architecture/resiliency/failure-mode-analysis#virtual-machine)
- [Tutorial: Create and deploy highly available virtual machines with Azure PowerShell](https://docs.microsoft.com/azure/virtual-machines/windows/tutorial-availability-sets)
