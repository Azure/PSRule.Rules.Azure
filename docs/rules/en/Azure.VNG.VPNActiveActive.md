---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Virtual Network Gateway
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VNG.VPNActiveActive.md
---

# Use Active-Active VPN gateways

## SYNOPSIS

Use VPN gateways configured to operate in an Active-Active configuration to reduce connectivity downtime.

## DESCRIPTION

VPN Gateways can be configured as either Active-Passive or Active-Active for Site-to-Site (S2S) connections.
When deploying VPN gateways, Azure deploys two instances for high-availability (HA).

When using an Active-Passive configuration, one instance is designated a standby for failover.

Gateways configured to use an Active-Active configuration:

- Establish two IPSEC tunnels, one from each instance per connection.
- Each instance will load balance network traffic.

## RECOMMENDATION

Consider using Active-Active VPN gateways to reduce connectivity downtime during HA failover.

## NOTES

Azure provisions a single instance for Basic (legacy) VPN gateways.
As a result, Basic VPN gateways do not support Active-Active connections.
To use Active-Active VPN connections, migrate to a gateway configured as VpnGw1 or higher SKU.

## LINKS

- [Highly Available Cross-Premises and VNet-to-VNet Connectivity](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-highlyavailable)
- [Update an existing VPN gateway](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-activeactive-rm-powershell#update-an-existing-vpn-gateway)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways#virtualnetworkgatewaypropertiesformat-object)
