---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.AvailabilityZone/
---

# Deploy virtual machine scale set instances using availability zones

## SYNOPSIS

Deploy virtual machine scale set instances using availability zones in supported regions to ensure high availability and resilience.

## DESCRIPTION

Virtual machine scale set supports the use of availability zones to provide zone redundancy. Zone redundancy enhances the resiliency and high availability of the virtual machine scale set by deploying instances across data centers in physically separated zones.

Virtual machine scale set utilizes scale rules, and as the set scales, it creates instances within the zones it is configured to use. If the set is configured to use only Zone 1, all new instances will be created in Zone 1. However, if the set is configured to use all three zones (Zone 1, Zone 2, and Zone 3), new instances will be distributed across these zones as it scales, ensuring balanced distribution and improved resilience.

Using availability zones is suitable for stateless workloads.

See documentation references below for additional limitations and important information.

## RECOMMENDATION

To improve the resiliency of virtual machine scale set instances against zone failures, it is recommended to use at least two (2) availability zones. This configuration enhances fault tolerance and ensures continued operation even if one zone experiences an outage.

## EXAMPLES

### Configure with Azure template

To set availability zones for a virtual machine scale set:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  "apiVersion": "2023-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "b2ms",
    "tier": "Standard",
    "capacity": 3
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Bicep

To set availability zones for a virtual machine scale set:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`.

For example:

```bicep
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: name
  location: location
  sku: {
    name: 'b2ms'
    tier: 'Standard'
    capacity: 3
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Availability zone support for Virtual Machine Scale Set](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
