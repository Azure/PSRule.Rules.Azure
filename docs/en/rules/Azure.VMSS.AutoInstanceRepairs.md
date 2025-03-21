---
severity: Important
pillar: Reliability
category: RE:07 Self-preservation
resource: Virtual Machine Scale Sets
resourceType: Microsoft.Compute/virtualMachineScaleSets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.AutoInstanceRepairs/
---

# Automatic instance repairs

## SYNOPSIS

Automatic instance repairs are enabled.

## DESCRIPTION

Enabling automatic instance repairs helps to achieve high application availability by automatically detecting and recovering unhealthy VM instances at runtime.

The automatic instance repair feature relies on health monitoring of individual VM instances in a scale set.
VM Instances in a scale set can be configured to emit application health status using either the Application Health extension or Load balancer health probes.
If an VM instance is found to be unhealthy, the scale set will perform a pre-configured repair action on the unhealthy VM instance.
Automatic instance repairs can be enabled in the Virtual Machine Scale Set model by using the `automaticRepairsPolicy` object.

See documentation references below for additional limitations and important information.

## RECOMMENDATION

Consider enabling automatic instance repairs to achieve high application availability by maintaining a set of healthy VM instances.

## EXAMPLES

### Configure with Azure template

To deploy virtual machine scale sets that pass this rule:

- Set the `properties.automaticRepairsPolicy.enabled` property to `true`.

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
    "capacity": 1
  },
  "properties": {
    "automaticRepairsPolicy": {
      "enabled": true
    }
  }
}
```

### Configure with Bicep

To deploy virtual machine scale sets that pass this rule:

- Set the `properties.automaticRepairsPolicy.enabled` property to `true`.

For example:

```bicep
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: name
  location: location
  sku: {
    name: 'b2ms'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    automaticRepairsPolicy: {
      enabled: true
    }
  }
}
```

## NOTES

This feature for virtual machine scale sets is currently in preview.

In order for automatic repairs policy to work properly, ensure that all the requirements for opting in to this feature are met.

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Automatic instance repairs](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-automatic-instance-repairs)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets#automaticrepairspolicy)
