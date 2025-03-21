---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Public IP address
resourceType: Microsoft.Network/publicIPAddresses
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

## EXAMPLES

### Configure with Azure template

To configure zone-redundancy for a Public IP address.

- Set `sku.name` to `Standard`.
- Set `zones` to `["1", "2", "3"]`.

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

To configure zone-redundancy for a Public IP address.

- Set `sku.name` to `Standard`.
- Set `zones` to `['1', '2', '3']`.

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

## NOTES

This rule is not applicable for public IP addresses used for Azure Bastion.
Azure Bastion does not currently support Availability Zones.
Public IP addresses with the following tags are automatically excluded from this rule:

- `resource-usage` tag set to `azure-bastion`.

This rule fails when `"zones"` is constrained to a single(zonal) zone, or set to `null`, `[]` when there are supported availability zones for the given region.

This rule passes if no zones exist for a given region or `"zones"` is set to `["1", "2", "3"]`.

Configure `AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/) for namespace `Microsoft.Network` and resource type `publicIpAddresses`.

```yaml
# YAML: The default AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability in Load Balancer](https://learn.microsoft.com/azure/reliability/reliability-load-balancer)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses)
