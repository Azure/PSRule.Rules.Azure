---
severity: Important
pillar: Reliability
category: Design
resource: Virtual Network Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.ERAvailabilityZoneSKU/
---

# Use availability zone SKU for ExpressRoute gateways

## SYNOPSIS

Use availability zone SKU for virtual network gateways deployed with ExpressRoute gateway type.

## DESCRIPTION

ExpressRoute gateways can be deployed in Availability Zones with the following SKUs:

- ErGw1AZ
- ErGw2AZ
- ErGw3AZ

This brings resiliency, scalability, and higher availability to ExpressRoute gateways.
Deploying ExpressRoute gateways in Azure Availability Zones physically and logically separates gateways within a region, while protecting your on-premises network connectivity to Azure from zone-level failures.

## RECOMMENDATION

Consider deploying ExpressRoute gateways with an availability zone SKU to improve reliability of virtual network gateways.

## NOTES

ExpressRoute gateway availability zones are managed via Public IP addresses, and are flagged separately under the `Azure.PublicIP.AvailabilityZone` rule.

## EXAMPLES

### Configure with Azure template

To configure an AZ SKU for an ExpressRoute gateway:

- Set `properties.gatewayType` to `'ExpressRoute'`
- Set `properties.sku.name` and `properties.sku.tier` to one of the following AZ SKUs:
  - `'ErGw1AZ'`
  - `'ErGw2AZ'`
  - `'ErGw3AZ'`

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
        "gatewayType": "ExpressRoute",
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
            "name": "ErGw1AZ",
            "tier": "ErGw1AZ"
        }
    }
}
```

### Configure with Bicep

To configure an AZ SKU for an ExpressRoute gateway:

- Set `properties.gatewayType` to `'ExpressRoute'`
- Set `properties.sku.name` and `properties.sku.tier` to one of the following AZ SKUs:
  - `'ErGw1AZ'`
  - `'ErGw2AZ'`
  - `'ErGw3AZ'`

For example:

```bicep
resource name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: name
  location: location
  tags: {}
  properties: {
    gatewayType: 'ExpressRoute'
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
      name: 'ErGw1AZ'
      tier: 'ErGw1AZ'
    }
  }
  dependsOn: [
    newPublicIpAddressName_resource
  ]
}
```

## LINKS

- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways?tabs=json)
- [About zone-redundant virtual network gateways in Azure Availability Zones](https://learn.microsoft.com/azure/vpn-gateway/about-zone-redundant-vnet-gateways)
- [ExpressRoute gateway SKUs](https://learn.microsoft.com/azure/expressroute/expressroute-about-virtual-network-gateways#gwsku)
- [Use zone-aware services](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-best-practices#use-zone-aware-services)
