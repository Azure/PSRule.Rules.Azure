---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.Agent.md
ms-content-id: e4f6f6e7-593c-4507-811d-778ee8ec9ac4
---

# VM agent is provisioned automatically

## SYNOPSIS

Ensure the VM agent is provisioned automatically.

## DESCRIPTION

The virtual machine (VM) agent is required for most functionality that interacts with the guest operating system.

VM extensions help reduce management overhead by providing an entry point to bootstrap monitoring and configuration of the guest operating system.
The VM agent is required to use any VM extensions.

## RECOMMENDATION

Automatically provision the VM agent for all supported operating systems, this is the default.
