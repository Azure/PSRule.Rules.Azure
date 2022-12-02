---
severity: Awareness
pillar: Operational Excellence
category: Deployment
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.NICAttached/
---

# Attach NIC or clean up

## SYNOPSIS

Network interfaces (NICs) should be attached.

## DESCRIPTION

Network interfaces (NICs) are used to attach services to a virtual network.
Each NIC is deployed as a separate resource, however are intended to be used with a related service.
A NIC that is not attached to a related service perform no purpose.

Example of services that use NICs include:

- Virtual Machines
- Private Endpoints

## RECOMMENDATION

Consider cleaning up NICs that are not required to reduce management complexity.
Also consider using Resource Groups to help manage the lifecycle of related resources together.

## LINKS

- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.network/networkinterfaces)
