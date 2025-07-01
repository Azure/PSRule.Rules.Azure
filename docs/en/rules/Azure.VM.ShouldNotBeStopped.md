---
reviewed: 2025-07-01
severity: Important
pillar: Cost Optimization
category: CO:07 Component costs
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ShouldNotBeStopped/
---

# Virtual Machine is stopped but still allocated

## SYNOPSIS

Azure Virtual Machines in a stopped state are still allocated and billed for compute usage.

## DESCRIPTION

Azure Virtual Machines (VMs) transition through several states during their lifecycle.

When a VM is in the _stopped_ state, the virtual machine is allocated on a host but not running.
VMs in a stopped state are still billed for compute usage.

When a VM is in the _deallocated_ state, the VM is not allocated on a host and is not billed for compute usage.
Other resources such as disks and public IP addresses may still incur costs.

By default, when a VM is stopped using the Azure portal, REST APIs, PowerShell, or CLI VMs are deallocated.
If the VM is shutdown from within the operating system, the VM is stopped but not deallocated.

## RECOMMENDATION

Consider fully de-allocating VMs instead of stopping VMs to reduce compute costs.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

Virtual Machines are reported based on their current state when in-flight data is collected.
There is no minimum duration for the state to be reported.

This rule may generate false positives in specific scenarios where the VM is intentionally stopped such as:

- VM that is currently stopped for snapshotting to generate a custom image.
- VM also an Active Directory Domain Controller that is offline for recovery or maintenance.

## LINKS

- [CO:07 Component costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-component-costs)
- [States and billing status of Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/states-billing)
