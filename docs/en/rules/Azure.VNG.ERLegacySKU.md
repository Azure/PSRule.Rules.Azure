---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Virtual Network Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.ERLegacySKU/
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

- [Estimated performances by gateway SKU](https://learn.microsoft.com/azure/expressroute/expressroute-about-virtual-network-gateways#aggthroughput)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways)
