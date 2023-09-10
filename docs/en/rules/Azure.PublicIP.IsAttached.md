---
severity: Important
pillar: Cost Optimization
category: Principles
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

Consider removing Public IP addresses that are no longer required reduce complexity and costs.

## LINKS

- [Cost optimization design principles](https://learn.microsoft.com/azure/well-architected/cost/principles)
- [Public IP address pricing](https://azure.microsoft.com/pricing/details/ip-addresses/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses)
