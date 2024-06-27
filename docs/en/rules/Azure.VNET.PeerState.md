---
reviewed: 2023-09-10
severity: Important
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.PeerState/
---

# VNET peer is not connected

## SYNOPSIS

VNET peering connections must be connected.

## DESCRIPTION

When peering virtual networks, a peering connection must be established from both virtual networks.
Only once both peering connections are in the Connected state will traffic be allowed to flow between the virtual networks.

Connections in the `Initiated` or `Disconnected` state should be investigated to determine if the connection is required.
When the connection is no longer required, it should be removed to prevent confusion during management and monitoring operations.

Most customers will use a hub and spoke topology to connect virtual networks.
For guidance on defining your network topology in Azure see Cloud Adoption Framework (CAF).

## RECOMMENDATION

Consider removing peering connections that are not longer required or complete peering connections.

## EXAMPLES

### Configure with Azure template

To deploy virtual networks that pass this rule:

- Create a peering connection from the spoke to the hub. AND
- Create a peering connection from the hub to the spoke.

For example a peering connection from a spoke to a hub:

```json
{
  "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
  "apiVersion": "2023-05-01",
  "name": "[format('{0}/{1}', parameters('spokeName'), format('peer-to-{0}', parameters('hubName')))]",
  "properties": {
    "remoteVirtualNetwork": {
      "id": "[resourceId('Microsoft.Network/virtualNetworks', parameters('hubName'))]"
    },
    "allowVirtualNetworkAccess": true,
    "allowForwardedTraffic": true,
    "allowGatewayTransit": false,
    "useRemoteGateways": true
  }
}
```

For example a peering connection from a hub to a spoke:

```json
{
  "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
  "apiVersion": "2023-05-01",
  "name": "[format('{0}/{1}', parameters('hubName'), format('peer-to-{0}', parameters('spokeName')))]",
  "properties": {
    "remoteVirtualNetwork": {
      "id": "[resourceId('Microsoft.Network/virtualNetworks', parameters('spokeName'))]"
    },
    "allowVirtualNetworkAccess": true,
    "allowForwardedTraffic": false,
    "allowGatewayTransit": true,
    "useRemoteGateways": false
  }
}
```

### Configure with Bicep

To deploy virtual networks that pass this rule:

- Create a peering connection from the spoke to the hub. AND
- Create a peering connection from the hub to the spoke.

For example a peering connection from a spoke to a hub:

```bicep
resource toHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: spoke
  name: 'peer-to-${hub.name}'
  properties: {
    remoteVirtualNetwork: {
      id: hub.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
  }
}
```

For example a peering connection from a hub to a spoke:

```bicep
resource toSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: hub
  name: 'peer-to-${spoke.name}'
  properties: {
    remoteVirtualNetwork: {
      id: spoke.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}
```

## NOTES

This rule applies when analyzing resources deployed to Azure (in-flight).

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Virtual network peering](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview)
- [Create, change, or delete a virtual network peering](https://learn.microsoft.com/azure/virtual-network/virtual-network-manage-peering#requirements-and-constraints)
- [Networking limits](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-subscription-service-limits#networking-limits)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Define an Azure network topology](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/define-an-azure-network-topology)
- [Azure VNET deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure VNET peering deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings)
