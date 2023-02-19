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

Consider fully deallocating VMs instead of stopping VMs to reduce cost.

## LINKS

- [Shut down underutilized instances](https://learn.microsoft.com/azure/architecture/framework/cost/optimize-vm#shut-down-underutilized-instances)
- [States and billing status of Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/states-billing)
