---
reviewed: 2023-09-10
severity: Important
pillar: Reliability
category: Requirements
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.StandardSKU/
---

# Public IP addresses should use Standard SKU

## SYNOPSIS

Public IP addresses should be deployed with Standard SKU for production workloads.

## DESCRIPTION

Public IP addresses allow Internet resources to communicate inbound to Azure resources.
Currently two SKUs are supported: Basic and Standard.

However, the Basic SKU for Public IP addresses will be retired on September 30, 2025.

The Standard SKU additionally offers security and redundancy improvements over the Basic SKU.
Including:

- Secure by default model and be closed to inbound traffic when used as a frontend.
  Network security groups are required to allow inbound traffic.
- Support for zone-redundancy and zonal deployments at creation.
  Zone-redundancy should mach the zone-redundancy of the resource it is attached to.
- Have an adjustable inbound originated flow idle timeout.
- More granular control of how traffic is routed between Azure and the Internet.

## RECOMMENDATION

Consider using Standard SKU for Public IP addresses deployed in production.

## EXAMPLES

### Configure with Azure template

To configure Standard SKU for a Public IP address.

- Set `sku.name` to `Standard`.

For example:

```json
{
  "type": "Microsoft.Network/publicIPAddresses",
  "apiVersion": "2023-05-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard",
    "tier": "Regional"
  },
  "properties": {
    "publicIPAddressVersion": "IPv4",
    "publicIPAllocationMethod": "Static",
    "idleTimeoutInMinutes": 4
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Bicep

To configure Standard SKU for a Public IP address.

- Set `sku.name` to `Standard`.

For example:

For example:

```bicep
resource pip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## LINKS

- [Meet application platform requirements](https://learn.microsoft.com/azure/well-architected/resiliency/design-requirements#meet-application-platform-requirements)
- [Standard Public IP addresses](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-addresses#sku)
- [Load Balancer and Availability Zones](https://learn.microsoft.com/azure/load-balancer/load-balancer-standard-availability-zones)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses)
