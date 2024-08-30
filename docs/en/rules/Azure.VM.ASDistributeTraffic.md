---
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ASDistributeTraffic/
---

# Distributing traffic

## SYNOPSIS

Ensure high availability by distributing traffic among members in an availability set.

## DESCRIPTION

An availability set is a logical grouping of virtual machines (VMs) in Azure, designed to enhance redundancy and reliability.
By organizing VMs within an availability set, Azure optimizes their placement across fault and update domains, minimizing the impact of hardware failures or maintenance events.

When VMs in an availability set are part of backend pools, traffic is evenly distributed among them, ensuring continuous application availability.
Even if one VM goes offline, the application remains accessible, thanks to the built-in redundancy provided by the availability set.

## RECOMMENDATION

Consider placing availability set members in backend pools.

## EXAMPLES

### Configure with Azure template

To deploy VM network interfaces that pass this rule:

- For each IP configuration specified in the `properties.ipConfigurations` property:
  - Ensure that the `properties.applicationGatewayBackendAddressPools.id` or/ and `properties.loadBalancerBackendAddressPools.id` property references at least one pool.

For example:

```json
{
  "type": "Microsoft.Network/networkInterfaces",
  "apiVersion": "2023-11-01",
  "name": "[parameters('nicName')]",
  "location": "[parameters('location')]",
  "properties": {
    "ipConfigurations": [
      {
        "name": "[parameters('ipConfig')]",
        "properties": {
          "privateIPAllocationMethod": "Dynamic",
          "subnet": {
            "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworkName'), parameters('subnetName'))]"
          },
          "loadBalancerBackendAddressPools": [
            {
              "id": "[resourceId('Microsoft.Network/loadBalancers/backendAddressPools', parameters('loadBalancerName'), 'backendPool')]"
            }
          ]
        }
      }
    ]
  }
}
```

### Configure with Bicep

To deploy VM network interfaces that pass this rule:

- For each IP configuration specified in the `properties.ipConfigurations` property:
  - Ensure that the `properties.applicationGatewayBackendAddressPools.id` or/ and `properties.loadBalancerBackendAddressPools.id` property references at least one pool.

For example:

```bicep
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipconfig
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'backendPool')
            }
          ]
        }
      }
    ]
  }
}
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Availability sets overview](https://learn.microsoft.com/azure/virtual-machines/availability-set-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networkinterfaces)
