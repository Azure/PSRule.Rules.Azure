---
severity: Important
category: Reliability
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VirtualNetwork.AppGwMinInstance.md
---

# Azure.VirtualNetwork.AppGwMinInstance

## SYNOPSIS

Application Gateways should use a minimum of two instances.

## DESCRIPTION

Application Gateways should use two or more instances to be covered by the Service Level Agreement (SLA).

## RECOMMENDATION

When using Application Gateway v1 or v2 with auto-scaling disabled, specify the number of instances to be two or more.

When auto-scaling is enabled with Application Gateway v2, configure the minimum number of instances to be two or more.

For more information see [Azure Application Gateway SLA](https://azure.microsoft.com/en-au/support/legal/sla/application-gateway/).
