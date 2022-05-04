---
severity: Important
pillar: Reliability
category: Design
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.AvailabilityZone/
---

# Public IP addresses should use availability zones

## SYNOPSIS

Public IP addresses deployed with Standard SKU should use availability zones in supported regions for high availability.

## DESCRIPTION

Public IP addresses using availability zones improve reliability and ensure availability during failure scenarios affecting a data center within a region.
A zone redundant Public IP address can spread across multiple availability zones, which ensures the Public IP address will continue running even if another zone has gone down.
Furthermore, this ensures Public Standard Load balancer frontend IPs using a zone-redundant Public IP address can survive zone failure.

## RECOMMENDATION

Consider using zone-redundant Public IP addresses deployed with Standard SKU.

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `"zones"` is constrained to a single(zonal) zone, or set to `null`, `[]` when there are supported availability zones for the given region.

This rule passes if no zones exist for a given region or `"zones"` is set to `["1", "2", "3"]`.

Configure `AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/) for namespace `Microsoft.Network` and resource type `publicIpAddresses`.

```yaml
# YAML: The default AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## EXAMPLES

### Configure with Azure template

To configure zone-redundancy for a Public IP address.

- Set `sku.name` to `Standard`.
- Set `zones` to `["1", "2", "3"]`.

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

To configure zone-redundancy for a Public IP address.

- Set `sku.name` to `Standard`.
- Set `zones` to `["1", "2", "3"]`.

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

- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/publicipaddresses?tabs=json)
- [Load Balancer and Availability Zones](https://docs.microsoft.com/azure/load-balancer/load-balancer-standard-availability-zones)
- [Use zone-aware services](https://docs.microsoft.com/azure/architecture/framework/resiliency/design-best-practices#use-zone-aware-services)