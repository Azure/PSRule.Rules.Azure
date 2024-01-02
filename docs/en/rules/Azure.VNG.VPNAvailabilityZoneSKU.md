---
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Virtual Network Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.VPNAvailabilityZoneSKU/
---

# Use availability zone SKU for VPN gateways

## SYNOPSIS

Use availability zone SKU for virtual network gateways deployed with VPN gateway type.

## DESCRIPTION

VPN gateways can be deployed in Availability Zones with the following SKUs:

- VpnGw1AZ
- VpnGw2AZ
- VpnGw3AZ
- VpnGw4AZ
- VpnGw5AZ

This brings resiliency, scalability, and higher availability to VPN gateways.
Deploying VPN gateways in Azure Availability Zones physically and logically separates gateways within a region, while protecting your on-premises network connectivity to Azure from zone-level failures.

## RECOMMENDATION

Consider deploying VPN gateways with an availability zone SKU to improve reliability of virtual network gateways.

## EXAMPLES

### Configure with Azure template

To configure an AZ SKU for a VPN gateway:

- Set `properties.gatewayType` to `'Vpn'`
- Set `properties.sku.name` and `properties.sku.tier` to one of the following AZ SKUs:
  - `'VpnGw1AZ'`
  - `'VpnGw2AZ'`
  - `'VpnGw3AZ'`
  - `'VpnGw4AZ'`
  - `'VpnGw5AZ'`

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworkGateways",
  "apiVersion": "2023-06-01",
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

To configure an AZ SKU for a VPN gateway:

- Set `properties.gatewayType` to `'Vpn'`
- Set `properties.sku.name` and `properties.sku.tier` to one of the following AZ SKUs:
  - `'VpnGw1AZ'`
  - `'VpnGw2AZ'`
  - `'VpnGw3AZ'`
  - `'VpnGw4AZ'`
  - `'VpnGw5AZ'`

For example:

```bicep
resource vng 'Microsoft.Network/virtualNetworkGateways@2023-06-01' = {
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
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}

```

## NOTES

VPN gateway availability zones are managed via Public IP addresses, and are flagged separately under the `Azure.PublicIP.AvailabilityZone` rule.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [About zone-redundant virtual network gateway in Azure availability zones](https://learn.microsoft.com/azure/vpn-gateway/about-zone-redundant-vnet-gateways)
- [VPN gateway SKUs](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways#gwsku)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways)
