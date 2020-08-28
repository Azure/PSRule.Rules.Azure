---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Application Gateway
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppGw.MinInstance.md
---

# Use two or more Application Gateway instances

## SYNOPSIS

Application Gateways should use a minimum of two instances.

## DESCRIPTION

Application Gateways should use two or more instances to be covered by the Service Level Agreement (SLA).

## RECOMMENDATION

When using Application Gateway v1 or v2 with auto-scaling disabled, specify the number of instances to be two or more.
When auto-scaling is enabled with Application Gateway v2, configure the minimum number of instances to be two or more.

## LINKS

- [Azure Application Gateway SLA](https://azure.microsoft.com/en-au/support/legal/sla/application-gateway/)
