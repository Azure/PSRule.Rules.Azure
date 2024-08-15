---
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ASDistributeTraffic/
---

# Distributing traffic

## SYNOPSIS

Ensure high availability by distributing traffic among members in an availability set.

## DESCRIPTION

An availability set is a logical grouping of virtual machines (VMs) in Azure, designed to enhance redundancy and reliability.
By organizing VMs within an availability set, Azure optimizes their placement across fault and update domains, minimizing the impact of hardware failures or maintenance events.

When VMs in an availability set are part of backend pools, traffic is evenly distributed among them, ensuring continuous application availability.
Even if one VM goes offline, the application remains accessible, thanks to the built-in redundancy provided by the availability set.

## RECOMMENDATION

Consider placing availability set members in backend pools.

## NOTES

This rule may produce false positives. To ensure accuracy, manually verify that all members of an availability set are correctly assigned to backend pools.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Availability sets overview](https://learn.microsoft.com/azure/virtual-machines/availability-set-overview)
- [Azure deployment reference - Virtual Machine](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
- [Azure deployment reference - Virtual Machine Network Interface](https://learn.microsoft.com/azure/templates/microsoft.network/networkinterfaces)
