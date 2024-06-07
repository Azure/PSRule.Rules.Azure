---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Virtual Network Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.MaintenanceConfig/
---

# Associate a customer-controlled maintenance configuration

## SYNOPSIS

Use a customer-controlled maintenance configuration for virtual network gateways.

## DESCRIPTION

Virtual network gateways require regular updates to maintain and enhance their functionality, reliability, performance, and security. These updates include patching software, upgrading networking components, and decommissioning outdated hardware.

By attaching virtual network gateways to a maintenance configuration, customers can schedule these updates to occur during a preferred maintenance window, ideally outside of business hours, to minimize disruptions.

Both the VPN and ExpressRoute virtual network gateway types support customer-controlled maintenance configurations.

## RECOMMENDATION

Consider using a customer-controlled maintenance configuration to efficiently schedule updates and minimize disruptions.

## EXAMPLES

### Configure with Azure template

To configure virtual network gateways that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```json
{
  "type": "Microsoft.Maintenance/configurationAssignments",
  "apiVersion": "2023-04-01",
  "name": "[parameters('assignmentName')]",
  "location": "[parameters('location')]",
  "scope": "[format('Microsoft.Network/virtualNetworkGateways/{0}', parameters('name'))]",
  "properties": {
    "maintenanceConfigurationId": "[parameters('maintenanceConfigurationId')]"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/virtualNetworkGateways', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To configure virtual network gateways that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```bicep
resource config 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: assignmentName
  location: location
  scope: virtualNetworkGateway
  properties: {
    maintenanceConfigurationId: maintenanceConfigurationId
  }
}
```

## NOTES

This feature is currently in preview for both the VPN and ExpressRoute virtual network gateway types.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Configure customer-controlled gateway maintenance for VPN Gateway](https://learn.microsoft.com/azure/vpn-gateway/customer-controlled-gateway-maintenance)
- [Configure customer-controlled gateway maintenance for ExpressRoute](https://learn.microsoft.com/azure/expressroute/customer-controlled-gateway-maintenance)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.maintenance/configurationassignments)
