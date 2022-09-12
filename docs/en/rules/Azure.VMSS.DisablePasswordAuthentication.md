---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.DisablePasswordAuthentication/
---

# Disable password authentication

## SYNOPSIS

Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities.

## DESCRIPTION

Linux virtual machine scale sets should have password authentication disabled to help with eliminating password-based attacks.

A common tactic observed used by adversaries against customers running Linux Virtual Machines (VMs) in Azure is password-based attacks.

[Azure security baseline for Linux Virtual Machines](https://docs.microsoft.com/security/benchmark/azure/baselines/virtual-machines-linux-security-baseline)
[Detailed steps: Create and manage SSH keys for authentication to a Linux VM in Azure](https://docs.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)

## RECOMMENDATION

Linux virtual machine scale sets should have password authentication disabled and instead use SSH keys.

## EXAMPLES

### Configure with Azure template

To deploy an virtual machine scale set that pass this rule:

- Set `properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication` to `true`.

### Configure with Bicep

To deploy an virtual machine scale set that pass this rule:

- Set `properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication` to `true`.

## LINKS

- [Identity and access management](https://docs.microsoft.com/azure/architecture/framework/security/design-identity)
- [Azure security baseline for Linux Virtual Machines](https://docs.microsoft.com/security/benchmark/azure/baselines/virtual-machines-linux-security-baseline)
- [Detailed steps: Create and manage SSH keys for authentication to a Linux VM in Azure](https://docs.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
