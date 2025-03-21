---
reviewed: 2023-12-07
severity: Awareness
pillar: Cost Optimization
category: CO:13 Personnel time
resource: Network Interface
resourceType: Microsoft.Network/networkInterfaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NIC.Attached/
---

# Attach NIC or clean up

## SYNOPSIS

Network interfaces (NICs) that are not used should be removed.

## DESCRIPTION

Network interfaces (NICs) are used to attach services to a virtual network (VNET).
Each NIC is deployed as a separate resource, however they are intended to be used with a related service.
A NIC that is not attached to a related service performs no purpose.

Keeping unused resources in code or deployed in Azure can lead to confusion and distract attention away from active resources.
Avoid unnecessary complexity that can increase the time required to develop, test, and maintain the workload.

Example of services that use NICs include:

- Virtual Machines.
- Private Endpoints.
- Private Link Services.

## RECOMMENDATION

Consider removing network interfaces that are not required to keep deployments lean and focus personnel time on active resources.
Also consider using Resource Groups to help manage the lifecycle of related resources together.

## LINKS

- [CO:13 Personnel time](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-personnel-time)
- [Design review checklist for Cost Optimization](https://learn.microsoft.com/azure/well-architected/cost-optimization/checklist)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networkinterfaces)
