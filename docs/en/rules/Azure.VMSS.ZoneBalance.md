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

Virtual machine scale sets (VMSS) scale-in/ out based on scaling rules your configured.
When scaling-out (adding instances) using availability zones instances are distribution over the configured zones.
However, it may not be possible to create an instance in a zone if there is an active issue affecting that zone.

The distribution behavior of instances across zones can be configured with two modes:

- **Best-effort zone balance** - Attempt to scale-in/ out while maintaining balance across zones.
  If that is not possible, allow temporary imbalance so the scaling operation can complete.
  On subsequent scale-out attempts, the scale set adds VMs to the zones needing more VMs to restore balance.
  Similarly, on subsequent scale-in attempts, the scale set removes VMs from zones that have more VMs than required to restore balance.
- **Strict zone balance** - Only allow the scaling operation to continue if zone balanced can be maintained.
  If that is not possible, the scaling operation will fail.

Key points:

- Both modes attempt to keep balance across zones but have a different approach when balance can't be maintained.
- Scale-out typically occurs to reduce pressure on the already provisioned instances by increasing capacity.
- If scale-out fails, the workload may become unstable due to increasing pressure.
- Balance only applies when two or more zones are configured on the VMSS.
- An outage or disruption in a zone may impact a higher percentage of the workload instances when the workload is not blanced.

## RECOMMENDATION

Consider using best-effort zone balancing to maintain stability of the workload under load.


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

<!-- external:avm res/compute/virtual-machine-scale-set zoneBalance -->

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Zone balancing](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones#zone-balancing)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
