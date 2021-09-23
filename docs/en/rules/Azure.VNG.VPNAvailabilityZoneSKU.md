---
severity: Important
pillar: Reliability
category: Design
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

## NOTES

VPN gateway availability zones are managed via Public IP addresses, and are flagged separately under the `Azure.PublicIP.AvailabilityZone` rule.

## EXAMPLES

### Configure with Azure template

To configure an AZ SKU for a VPN gateway:

- Set `properties.gatewayType` to `'Vpn'`
- Set `properties.sku.name` and `properties.sku.tier` to an AZ SKU which matches `'^VpnGw[1-5]AZ$'`

For example:

```json
{
    "apiVersion": "2020-11-01",
    "name": "[parameters('name')]",
    "type": "Microsoft.Network/virtualNetworkGateways",
    "location": "[parameters('location')]",
    "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', parameters('newPublicIpAddressName'))]"
    ],
    "tags": {},
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
                    "publicIpAddress": {
                        "id": "[resourceId('vpn-rg', 'Microsoft.Network/publicIPAddresses', parameters('newPublicIpAddressName'))]"
                    }
                }
            }
        ],
        "vpnType": "[parameters('vpnType')]",
        "vpnGatewayGeneration": "[parameters('vpnGatewayGeneration')]",
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
- Set `properties.sku.name` and `properties.sku.tier` to an AZ SKU which matches `'^VpnGw[1-5]AZ$'`

For example:

```bicep
resource name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: name
  location: location
  tags: {}
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
            id: resourceId('vpn-rg', 'Microsoft.Network/publicIPAddresses', newPublicIpAddressName)
          }
        }
      }
    ]
    vpnType: vpnType
    vpnGatewayGeneration: vpnGatewayGeneration
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
  dependsOn: [
    newPublicIpAddressName_resource
  ]
}
```

## LINKS

- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways?tabs=json)
- [About zone-redundant virtual network gateways in Azure Availability Zones](https://docs.microsoft.com/azure/vpn-gateway/about-zone-redundant-vnet-gateways)
- [VPN gateway SKUs](https://docs.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways#gwsku)
- [Use zone-aware services](https://docs.microsoft.com/azure/architecture/framework/resiliency/design-best-practices#use-zone-aware-services)