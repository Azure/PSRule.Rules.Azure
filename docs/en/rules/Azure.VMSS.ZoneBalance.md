---
severity: Important
pillar: Reliability
category: RE:07 Self-preservation
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.ZoneBalance/
---

# Deploy virtual machine scale set instances using best-effort zone balance

## SYNOPSIS

Deploy virtual machine scale set instances using the best-effort zone balance in supported regions to ensure an approximately balanced distribution of instances across availability zones.

## DESCRIPTION

When deploying virtual machine scale sets across multiple availability zones, the distribution behavior of instances can be configured with two modes:

- Best-effort zone balance
- Strict zone balance

Best-effort zone balance: This mode attempts to scale in and out while maintaining a balance across zones. If maintaining zone balance is not possible (e.g., if a zone goes down and new VMs can’t be created in that zone), the scale set allows temporary imbalance to continue scaling operations. On subsequent scale-out attempts, the scale set adds VMs to the zones needing more VMs to restore balance. Similarly, on subsequent scale-in attempts, the scale set removes VMs from zones that have more VMs than required to restore balance.

Strict zone balance: This mode ensures that VM instances are strictly balanced across all specified zones, without allowing any temporary imbalance. This can cause the scaling operations to be paused or fail if the zone balance cannot be maintained.

## RECOMMENDATION

To enhance the distribution of virtual machine scale set instances, it is recommended to use the best-effort zone balance approach. This configuration helps in maintaining a balanced distribution of VMs across zones while allowing flexibility during scale operations.

## EXAMPLES

### Configure with Azure template

To set best-effort zone balance for a virtual machine scale set:

- Set the `properties.zoneBalance` property to `false`.

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
  "properties": {
    "zoneBalance": false
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Bicep

To set best-effort zone balance for a virtual machine scale set:

- Set the `properties.zoneBalance` property to `false`.

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
  properties: {
    zoneBalance: false
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Zone balancing](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones#zone-balancing)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
