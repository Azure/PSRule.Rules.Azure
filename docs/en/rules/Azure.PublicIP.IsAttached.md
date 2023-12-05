---
severity: Important
pillar: Cost Optimization
category: CO:14 Consolidation
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.IsAttached/
ms-content-id: 9222ec9f-7eea-4301-bee6-3022c9008874
---

# Remove unused Public IP addresses

## SYNOPSIS

Public IP addresses should be attached or cleaned up if not in use.

## DESCRIPTION

Unattached static Public IP address are charged when not in use.

## RECOMMENDATION

Consider removing Public IP addresses that are no used.

## NOTES

This rule applies when analyzing public IP addresses (in-flight) running within Azure.

## LINKS

- [CO:14 Consolidation](https://learn.microsoft.com/azure/well-architected/cost-optimization/consolidation)
- [Design review checklist for Cost Optimization](https://learn.microsoft.com/azure/well-architected/cost-optimization/checklist)
- [Public IP address pricing](https://azure.microsoft.com/pricing/details/ip-addresses/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses)
