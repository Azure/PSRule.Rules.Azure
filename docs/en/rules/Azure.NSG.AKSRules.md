---
reviewed: 2022-09-21
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.AKSRules/
---

# No custom NSG rules for AKS managed NSGs

## SYNOPSIS

AKS Network Security Group (NSG) should not have custom rules.

## DESCRIPTION

AKS manages the Network Security Group (NSG) allocated to the cluster. There should be no custom rules added as it may cause
conflicts, break the AKS cluster or have an unexpected result.

## RECOMMENDATION

Do not create custom Network Security Group (NSG) rules for an AKS managed NSG.

## LINKS

- [AKS Network Security](https://learn.microsoft.com/azure/aks/concepts-security#network-security)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networksecuritygroups)
