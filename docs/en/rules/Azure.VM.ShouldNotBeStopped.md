---
reviewed: 2024-03-11
severity: Important
pillar: Cost Optimization
category: CO:07 Component costs
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ShouldNotBeStopped/
---

# VMs should not be stopped state

## SYNOPSIS

Azure VMs should be running or in a deallocated state.

## DESCRIPTION

Azure Virtual Machines in a stopped state are still billed hourly for compute usage.
Therefor VMs should generally be in a deallocated or running state.

## RECOMMENDATION

Consider fully de-allocating VMs instead of stopping VMs to reduce cost.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [CO:07 Component costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-component-costs)
- [States and billing status of Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/states-billing)
