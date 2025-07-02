---
reviewed: 2025-07-03
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Virtual Network Gateway
resourceType: Microsoft.Network/virtualNetworkGateways,Microsoft.Maintenance/configurationAssignments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.MaintenanceConfig/
---

# Associate a customer-controlled maintenance configuration

## SYNOPSIS

Use a customer-controlled maintenance configuration for virtual network gateways.

## DESCRIPTION

Virtual network gateways are critical infrastructure components that require regular maintenance updates to ensure optimal
functionality, reliability, performance, and security.

In most cases, these updates are carefully planned to minimize their impact on customer operations.
Azure schedules updates during non-business hours in the gateway region, and customers with robust architecture
typically experience minimal disruption to normal business activities.
However, there might be instances where customers are affected by these updates, particularly in scenarios where:

- Business operations span multiple time zones.
- Maintenance windows need to align with other regular scheduled activities.
- Organizations require predictable maintenance schedules for compliance or operational reasons.

Customer-controlled maintenance configurations*provide organizations with the ability to define specific maintenance
windows when guest OS and service updates occur.
These updates account for most of the maintenance items that cause concern for customers.
Some other types of updates, including host, and critical security updates are outside the scope of customer-controlled maintenance.

## RECOMMENDATION

Consider using a customer-controlled maintenance configuration to predictably schedule updates and minimize disruptions.

## EXAMPLES

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

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Configure customer-controlled gateway maintenance for VPN Gateway](https://learn.microsoft.com/azure/vpn-gateway/customer-controlled-gateway-maintenance)
- [Configure customer-controlled gateway maintenance for ExpressRoute](https://learn.microsoft.com/azure/expressroute/customer-controlled-gateway-maintenance)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.maintenance/configurationassignments)
