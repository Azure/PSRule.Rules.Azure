---
severity: Important
pillar: Reliability
category: Design
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.StandardSKU/
---

# Public IP addresses should use Standard SKU

## SYNOPSIS

Public IP addresses should be deployed with Standard SKU for production workloads.

## DESCRIPTION

Standard Public IPs are designed with the "secure by default" model and are closed to inbound traffic when uses as a frontend.
Network security groups are required to allow inbound traffic.
For example, a network security group can be attached on the NIC of a virtual machine with a Standard Public IP address attached.
It also enables zone-redundancy(all three zones), zonal(constrained to a single zone) or no-zone(no pre-selected availability zone).
It can also choose routing preferences between Microsoft global network and the internet.

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
    "apiVersion": "2020-11-01",
    "name": "[parameters('publicIPAddresses_test_ip_name')]",
    "location": "australiaeast",
    "sku": {
        "name": "Standard",
        "tier": "Regional"
    },
    "zones": [
        "2",
        "3",
        "1"
    ],
    "properties": {
        "ipAddress": "[parameters('publicIPAddresses_ip_address')]",
        "publicIPAddressVersion": "IPv4",
        "publicIPAllocationMethod": "Static",
        "idleTimeoutInMinutes": 4,
        "ipTags": []
    }
}
```

### Configure with Bicep

To configure Standard SKU for a Public IP address.

- Set `sku.name` to `Standard`.

For example:

For example:

```bicep
resource publicIPAddresses_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '2'
    '3'
    '1'
  ]
  properties: {
    ipAddress: ipAddress
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}
```

## LINKS

- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.network/publicipaddresses?tabs=json)
- [Standard Public IP addresses](https://docs.microsoft.com/azure/virtual-network/public-ip-addresses#standard)
- [Load Balancer and Availability Zones](https://docs.microsoft.com/azure/load-balancer/load-balancer-standard-availability-zones)
- [Meet application platform requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements#meet-application-platform-requirements)
