---
severity: Important
pillar: Cost Optimization
category: Resource usage
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ShouldNotBeStopped/
---

# VMs should not be stopped state

## SYNOPSIS

Azure VMs should be running or in a deallocated state.

## DESCRIPTION

Azure Virtual Machines in a stopped state are still billed hourly for compute usage. Therefor VMs should generally be in a deallocated or running state.

## RECOMMENDATION

Consider fully deallocating VMs instead of stopping VMs.

## NOTES

## LINKS

- [States and billing status of Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/states-billing)
