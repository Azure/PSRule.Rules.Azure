---
severity: Important
category: Performance
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VirtualMachine.BasicSku.md
ms-content-id: 49cef14e-19f0-4a54-be14-7c27a0347b4c
---

# Azure.VirtualMachine.BasicSku

## SYNOPSIS

Virtual machines (VMs) should not use Basic sizes.

## DESCRIPTION

VMs can be deployed in Basic or Standard sizes. Basic VM sizes are suitable only for entry level development scenarios.

## RECOMMENDATION

Basic VM sizes are not suitable for production workloads or intensive development workloads. Consider migration to an alternative Standard VM size.

For more information see [Sizes for Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes) and [Sizes for Linux virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes).
