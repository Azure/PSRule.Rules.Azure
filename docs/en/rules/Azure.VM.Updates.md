---
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Updates/
ms-content-id: 8781c21b-4e6a-47fe-860d-d2191f0304ae
---

# Automatic updates are enabled

## SYNOPSIS

Ensure automatic updates are enabled at deployment.

## DESCRIPTION

Window virtual machines (VMs) have automatic updates turned on at deployment time by default.
The option can be enabled/ disabled at deployment time or updated for VM scale sets.

Enabling this option does not prevent automatic updates being disabled or reconfigured within the operating system after deployment.

## RECOMMENDATION

Enable automatic updates at deployment time, then reconfigure as required to meet patch management requirements.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Automatic Guest Patching for Azure Virtual Machines and Scale Sets](https://learn.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
