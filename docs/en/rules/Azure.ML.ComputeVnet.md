---
reviewed: 2023-10-10
severity: Critical
pillar: Security
category: Connectivity
resource: Machine Learning
resourceType: Microsoft.MachineLearningServices/workspaces/computes
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.ComputeVnet/
---

# Host ML Compute in VNet

## SYNOPSIS

Azure Machine Learning Computes should be hosted in a virtual network (VNet).

## DESCRIPTION

When using Azure Machine Learning (ML), you can configure compute instances to be private or accessible from the public Internet.
By default, the ML compute is configured to be accessible from the public Internet.

ML compute can be deployed into an virtual network (VNet) to provide private connectivity, enhanaced security, and isolation.
Using a VNet reduces the attack surface for your solution, and the chances of data exfiltration.
Additionally, network controls such as Network Security Groups (NSGs) can be used to further restrict access.

## RECOMMENDATION

Consider using ML - compute hosted in a VNet to provide private connectivity, enhanaced security, and isolation.

## EXAMPLES

### Configure with Azure template

To deploy an ML - compute that passes this rule:

- Set the `properties.properties.subnet.id` property with a resource Id of a specific VNET subnet.

For example:

```json
{
  "type": "Microsoft.MachineLearningServices/workspaces/computes",
  "apiVersion": "2023-06-01-preview",
  "name": "[format('{0}/{1}', parameters('name'), parameters('name'))]",
  "location": "[parameters('location')]",
  "properties": {
    "computeType": "ComputeInstance",
    "disableLocalAuth": true,
    "properties": {
      "vmSize": "[parameters('vmSize')]",
      "idleTimeBeforeShutdown": "PT15M",
      "subnet": {
        "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', split('vnet/subnet', '/')[0], split('vnet/subnet', '/')[1])]"
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.MachineLearningServices/workspaces', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy an ML - compute that passes this rule:

- Set the `properties.properties.subnet.id` property with a resource Id of a specific VNET subnet.

For example:

```bicep
resource compute_instance 'Microsoft.MachineLearningServices/workspaces/computes@2023-06-01-preview' = {
  parent: workspace
  name: name
  location: location
  properties: {
    computeType: 'ComputeInstance'
    disableLocalAuth: true
    properties: {
      vmSize: vmSize
      idleTimeBeforeShutdown: 'PT15M'
      subnet: {
        id: subnet.id
      }
    }
  }
}
```

## LINKS

- [WAF - Azure services for securing network connectivity](https://learn.microsoft.com/azure/well-architected/security/design-network-connectivity)
- [Managed compute in a managed virtual network](https://learn.microsoft.com/azure/machine-learning/how-to-managed-network-compute)
- [ML - Network security and isolation](https://learn.microsoft.com/azure/machine-learning/concept-enterprise-security#network-security-and-isolation)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary#compute)
- [NS-1: Establish network segmentation boundaries](https://learn.microsoft.com/security/benchmark/azure/baselines/machine-learning-service-security-baseline#ns-1-establish-network-segmentation-boundaries)
- [Azure deployment reference - Compute objects](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces/computes#compute-objects)
- [Azure deployment reference - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces)
