---
reviewed: 2024-06-04
severity: Critical
pillar: Reliability
category: RE:04 Target metrics
resource: Virtual Network Gateway
resourceType: Microsoft.Network/virtualNetworkGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.VPNLegacySKU/
---

# Migrate from legacy VPN gateway SKUs

## SYNOPSIS

Migrate from legacy SKUs to improve reliability and performance of VPN gateways.

## DESCRIPTION

When deploying a VPN gateway a number of options are available including SKU/ size.
The gateway SKU affects the reliance and performance of the underlying gateway instances.
Previously the following SKUs were available however have been depreciated.

- `Basic`
- `Standard`
- `HighPerformance`

The Standard and High Performance SKUs will be deprecated on September 30, 2025.

## RECOMMENDATION

Consider redeploying VPN gateways using new SKUs to improve reliability and performance of gateways.

## EXAMPLES

### Configure with Azure template

To configure VPN gateways that pass this rule:

- Set `properties.gatewayType` to `Vpn`.
- Set `properties.sku.name` and `properties.sku.tier` to one of the following SKUs:
  - `VpnGw1`
  - `VpnGw1AZ`
  - `VpnGw2`
  - `VpnGw2AZ`
  - `VpnGw3`
  - `VpnGw3AZ`
  - `VpnGw4`
  - `VpnGw4AZ`
  - `VpnGw5`
  - `VpnGw5AZ`

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworkGateways",
  "apiVersion": "2023-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "gatewayType": "Vpn",
    "ipConfigurations": [
      {
        "name": "default",
        "properties": {
          "privateIPAllocationMethod": "Dynamic",
          "subnet": {
            "id": "[parameters('subnetId')]"
          },
          "publicIPAddress": {
            "id": "[parameters('pipId')]"
          }
        }
      }
    ],
    "activeActive": true,
    "vpnType": "RouteBased",
    "vpnGatewayGeneration": "Generation2",
    "sku": {
      "name": "VpnGw1AZ",
      "tier": "VpnGw1AZ"
    }
  }
}
```

### Configure with Bicep

To configure VPN gateways that pass this rule:

- Set `properties.gatewayType` to `Vpn`.
- Set `properties.sku.name` and `properties.sku.tier` to one of the following SKUs:
  - `VpnGw1`
  - `VpnGw1AZ`
  - `VpnGw2`
  - `VpnGw2AZ`
  - `VpnGw3`
  - `VpnGw3AZ`
  - `VpnGw4`
  - `VpnGw4AZ`
  - `VpnGw5`
  - `VpnGw5AZ`

For example:

```bicep
resource vng 'Microsoft.Network/virtualNetworkGateways@2023-11-01' = {
  name: name
  location: location
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pipId
          }
        }
      }
    ]
    activeActive: true
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}
```

<!-- external:avm avm/res/network/virtual-network-gateway skuName -->

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Change to the new gateway SKUs](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-skus-legacy#change)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways)
