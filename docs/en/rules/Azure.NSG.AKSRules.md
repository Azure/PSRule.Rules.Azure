---
reviewed: 2022/09/21
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.AKSRules/
---

# Use valid NSG names

## SYNOPSIS

AKS Network Security Group (NSG) should not have custom rules.

## DESCRIPTION

AKS manages the Network Security Group (NSG) allocated to the cluster. There should be no custom rules added.

## RECOMMENDATION

Do not create custom Network Security Group (NSG) rules for an AKS managed NSG.

## LINKS

- [AKS Network Security](https://learn.microsoft.com/en-us/azure/aks/concepts-security#network-security)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/networksecuritygroups)
