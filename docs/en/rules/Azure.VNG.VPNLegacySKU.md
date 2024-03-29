---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Virtual Network Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.VPNLegacySKU/
---

# Migrate from legacy VPN gateway SKUs

## SYNOPSIS

Migrate from legacy SKUs to improve reliability and performance of VPN gateways.

## DESCRIPTION

When deploying a VPN gateway a number of options are available including SKU/ size.
The gateway SKU affects the reliance and performance of the underlying gateway instances.
Previously the following SKUs were available however have been depreciated.

- Basic
- Standard
- HighPerformance

## RECOMMENDATION

Consider redeploying VPN gateways using new SKUs to improve reliability and performance of gateways.

## LINKS

- [Change to the new gateway SKUs](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-skus-legacy#change)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways)
