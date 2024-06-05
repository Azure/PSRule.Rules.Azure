---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Firewall
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Firewall.AvailabilityZones/

# Deploy firewall instances using availability zones

## SYNOPSIS

Deploy firewall instances using availability zones in supported regions to ensure high availability and resilience.

## DESCRIPTION

Azure Firewall supports the use of availability zones to provide zone redundancy. Zone redundancy enhances the resiliency and high availability of the firewall by deploying instances across data centers in physically separated zones.

Azure Firewall utilizes auto-scaling, and as the firewall scales, it creates instances within the zones it is configured to use. If the firewall is configured to use only Zone 1, all new instances will be created in Zone 1. However, if the firewall is configured to use all three zones (Zone 1, Zone 2, and Zone 3), new instances will be distributed across these zones as it scales, ensuring balanced distribution and improved resilience.

## RECOMMENDATION

To improve the resiliency of firewall instances against zone failures, it is recommended to use at least two (2) availability zones. This configuration enhances fault tolerance and ensures continued operation even if one zone experiences an outage.

## EXAMPLES

### Configure with Azure template

To set availability zones for a firewall:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`.

For example:

```json
{
  "type": "Microsoft.Network/azureFirewalls",
  "apiVersion": "2023-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "name": "AZFW_VNet",
      "tier": "Premium"
    },
    "firewallPolicy": {
      "id": "[resourceId('Microsoft.Network/firewallPolicies', format('{0}_policy', parameters('name')))]"
    }
  },
  "zones": [
    "1",
    "2",
    "3"
  ],
  "dependsOn": [
    "firewall_policy"
  ]
}
```

### Configure with Bicep

To set availability zones for a firewall:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`.

For example:

```bicep
resource firewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    firewallPolicy: {
      id: firewall_policy.id
    }
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## NOTES

Availability zones must be configured during the initial deployment. It is not possible to modify an existing firewall to include availability zones after it has been deployed.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Availability zone support for Azure Firewall](https://learn.microsoft.com/azure/firewall/features#availability-zones)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.network/azurefirewalls)
