---
severity: Important
pillar: Cost Optimization
category: Resource usage
resource: Public IP address
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.PublicIP.IsAttached.md
ms-content-id: 9222ec9f-7eea-4301-bee6-3022c9008874
---

# Remove unused Public IP addresses

## SYNOPSIS

Public IP address should be attached or removed.

## DESCRIPTION

Unattached static Public IP address are charged when not in use.

## RECOMMENDATION

Consider removing Public IP addresses that are no longer required reduce complexity and costs.

## LINKS

- [Public IP address pricing](https://azure.microsoft.com/pricing/details/ip-addresses/)
