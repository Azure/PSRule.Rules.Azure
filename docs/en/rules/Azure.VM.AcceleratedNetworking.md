---
severity: Important
pillar: Performance Efficiency
category: PE:07 Code and infrastructure
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.AcceleratedNetworking/
ms-content-id: c2b60867-f911-45d6-8d9a-a22bf0a7e729
---

# Use accelerated networking

## SYNOPSIS

Use accelerated networking for supported operating systems and VM types.

## DESCRIPTION

Enabling accelerated networking for a virtual machine (VM) greatly improves networking performance.
Accelerated networking work by enabling single root I/O virtualization (SR-IOV) to a VM.
SR-IOV reduces latency, jitter, and CPU utilization network demanding workloads.

Accelerated networking is available for supported operating systems and VM types.

## RECOMMENDATION

Consider enabling accelerated networking for supported operating systems and VM types.

## LINKS

- [PE:07 Code and infrastructure](https://learn.microsoft.com/azure/well-architected/performance-efficiency/optimize-code-infrastructure)
- [Create a Linux virtual machine with Accelerated Networking using Azure CLI](https://learn.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-cli)
- [Create a Windows VM with accelerated networking using Azure PowerShell](https://learn.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-powershell)
