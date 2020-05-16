---
severity: Important
category: Reliability
resource: ExpressRoute
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.ERGateway.LegacySKU.md
---

# Migrate from legacy ER gateway SKUs

## SYNOPSIS

Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways.

## DESCRIPTION

When deploying a ER gateway a number of options are available including SKU/ size.
The gateway SKU affects the reliance and performance of the underlying gateway instances.
Previously the following SKUs were available however have been depreciated.

- Basic

## RECOMMENDATION

Consider redeploying ER gateways using new SKUs to improve reliability and performance of gateways.

## LINKS

- [Estimated performances by gateway SKU](https://docs.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways#aggthroughput)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways)
