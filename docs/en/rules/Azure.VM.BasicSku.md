---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.BasicSku/
ms-content-id: 49cef14e-19f0-4a54-be14-7c27a0347b4c
---

# Avoid Basic VM SKU

## SYNOPSIS

Virtual machines (VMs) should not use Basic sizes.

## DESCRIPTION

VMs can be deployed in Basic or Standard sizes.
Basic VM sizes are suitable only for entry level development scenarios.

## RECOMMENDATION

Basic VM sizes are not suitable for production workloads or intensive development workloads.
Consider migration to an alternative Standard VM size.

## LINKS

- [Sizes for Windows virtual machines in Azure](https://learn.microsoft.com/azure/virtual-machines/windows/sizes)
- [Sizes for Linux virtual machines in Azure](https://learn.microsoft.com/azure/virtual-machines/linux/sizes)
