---
reviewed: 2023-10-06
severity: Critical
pillar: Cost Optimization
category: CO:06 Usage and billing increments
resource: Machine Learning
resourceType: Microsoft.MachineLearningServices/workspaces/computes
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.ComputeIdleShutdown/
---

# Configure idle shutdown for compute instances

## SYNOPSIS

Configure an idle shutdown timeout for Machine Learning compute instances.

## DESCRIPTION

Machine Learning uses compute instances as a training or inference compute for development and testing.
It's similar to a virtual machine on the cloud.

To avoid getting charged for a compute instance that is switched on but not being actively used,
you can configure when to automatically shutdown compute instances due to inactivity.

## RECOMMENDATION

Consider configuring ML - Compute Instances to automatically shutdown after a period of inactivity to optimize compute costs.

## EXAMPLES

### Configure with Azure template

To deploy compute instances that passes this rule:

- Set the `properties.properties.idleTimeBeforeShutdown` property with a ISO 8601 formatted string.
  i.e. For an idle shutdown time of 15 minutes use `PT15M`.

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
      "idleTimeBeforeShutdown": "PT15M"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.MachineLearningServices/workspaces', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy compute instances that passes this rule:

- Set the `properties.properties.idleTimeBeforeShutdown` property with a ISO 8601 formatted string.
  i.e. For an idle shutdown time of 15 minutes use `PT15M`.

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
    }
  }
}
```

## LINKS

- [CO:06 Usage and billing increments](https://learn.microsoft.com/azure/well-architected/cost-optimization/align-usage-to-billing-increments)
- [AI + Machine Learning cost estimates](https://learn.microsoft.com/azure/well-architected/cost/provision-ai-ml)
- [Configure idle shutdown](https://learn.microsoft.com/azure/machine-learning/how-to-create-compute-instance#configure-idle-shutdown)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary#compute)
- [Azure deployment reference - Compute objects](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces/computes#compute-objects)
- [Azure deployment reference - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces)
