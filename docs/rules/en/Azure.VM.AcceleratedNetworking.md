---
severity: Important
pillar: Performance Efficiency
category: Performance
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.AcceleratedNetworking.md
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

- [Create a Linux virtual machine with Accelerated Networking using Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli)
- [Create a Windows VM with accelerated networking using Azure PowerShell](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-powershell)
