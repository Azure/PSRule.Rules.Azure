---
reviewed: 2023-10-10
severity: Critical
pillar: Security
category: Networking
resource: ML
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.ComputeVnet/
---

# Name of rule

## SYNOPSIS

Azure Machine Learning Computes should be hosted in a virtual network (VNet).

## DESCRIPTION

Azure Virtual Networks (VNets) provide enhanced security and isolation for your Azure Machine Learning Compute Clusters and Instances, as well as subnets, access control policies, and other features to further restrict access. When a compute is configured with a virtual network, it is not publicly addressable and can only be accessed from virtual machines and applications within the virtual network.

## RECOMMENDATION

ML - Compute should be hosted in a virtual network (VNet) as part of a broader security strategy. 

## EXAMPLES

### Configure with Azure template

To deploy an ML - compute that complies with this rule:

- update the compute properties to reference a specific subnet.

For example:

```json

{
    "type": "Microsoft.MachineLearningServices/workspaces/computes",
    "apiVersion": "2023-04-01",
    "name": "[format('{0}/{1}', 'example-ws', parameters('name'))]",
    "location": "[parameters('location')]",
    "properties": {
      "managedResourceGroupId": "[subscriptionResourceId('Microsoft.Resources/resourceGroups', 'example-rg')]",
      "computeType": "[parameters('computeType')]",
      "properties": {
        "vmSize": "[parameters('vmSize')]",
          "subnet": {
            "id": "[parameters('subnetId')]"
          }
      }
    }
}

```

### Configure with Bicep

To deploy an ML - compute that complies with this rule:

- update the compute properties to reference a specific subnet.

For example:

```bicep

resource aml_compute_instance 'Microsoft.MachineLearningServices/workspaces/computes@2023-04-01' ={
  name: '${mlWorkspace.name}/${name}'
  location: location

  properties:{
    managedResourceGroupId: managedRg.id
    computeType: ComputeType
    properties: {
      vmSize: vmSize 
      subnet:{
        id: subnet.id
      }
    }
  }
}
```


## LINKS

- [Managed compute in a managed virtual network](https://learn.microsoft.com/azure/machine-learning/how-to-managed-network-compute?view=azureml-api-2&tabs=azure-cli)
- [ML - Compute objects](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep#resource-format)
- [ML - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/2023-04-01/workspaces?pivots=deployment-language-bicep)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary?view=azureml-api-2#compute)
- [WAF - Azure services for securing network connectivity](https://learn.microsoft.com/azure/well-architected/security/design-network-connectivity)

