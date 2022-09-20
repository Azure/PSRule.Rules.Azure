---
severity: Awareness
pillar: Operational Excellence
category: Principles
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.Associated/
---

# Associate NSGs or clean up

## SYNOPSIS

Network Security Groups (NSGs) should be associated to a subnet or network interface.

## DESCRIPTION

NSGs basic stateful firewalls that are deployed as separate resources.
Each NSG can be associated to one or more network interfaces or subnets.
NSGs that are not associated with a network interface or subnet perform no purpose.

## RECOMMENDATION

Consider cleaning up NSGs that are not required to reduce technical debt.
Also consider using Resource Groups to help manage the lifecycle of related resources together.

## LINKS

- [Operational excellence principles](https://docs.microsoft.com/azure/architecture/framework/devops/principles)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)
- [Network security groups](https://docs.microsoft.com/azure/virtual-network/security-overview)
