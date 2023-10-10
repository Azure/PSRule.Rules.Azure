---
reviewed: 2023-10-10
severity: Critical
pillar: Security
category: Provision
resource: ML
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.DisableLocalAuth/
---

# Name of rule

## SYNOPSIS

Azure Machine Learning compute resources should have local authentication methods disabled.

## DESCRIPTION

Controls whether an Azure Machine Learning compute cluster or instance should disable local authentication (SSH).

## RECOMMENDATION

ML - Compute should be configured with local authentication disabled as part of a broader security strategy. 

## EXAMPLES

### Configure with Azure template

To deploy an ML - compute that complies with this rule:

- Set the `disableLocalAuth` property value to true.

For example:

```json

{
    "type": "Microsoft.MachineLearningServices/workspaces/computes",
    "apiVersion": "2023-04-01",
    "name": "[format('{0}/{1}', 'example-ws', parameters('name'))]",
    "location": "[parameters('location')]",
    "properties": {
      "managedResourceGroupId": "[subscriptionResourceId('Microsoft.Resources/resourceGroups', 'psrule')]",
      "computeType": "[parameters('computeType')]",
      "disableLocalAuth": true,
      "properties": {
        "vmSize": "[parameters('vmSize')]",
      }
    }
}

```

### Configure with Bicep

To deploy an ML - compute that complies with this rule:

- Set the `disableLocalAuth` property value to `true`.

For example:

```bicep

resource aml_compute_instance 'Microsoft.MachineLearningServices/workspaces/computes@2023-04-01' ={
  name: '${mlWorkspace.name}/${name}'
  location: location

  properties:{
    managedResourceGroupId: managedRg.id
    computeType: ComputeType
    disableLocalAuth: true
    properties: {
      vmSize: vmSize 
    }
  }
}

## LINKS

- [Disable local authentication](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-integrate-azure-policy?view=azureml-api-2#disable-local-authentication)
- [ML - Compute objects](https://learn.microsoft.com/en-gb/azure/templates/microsoft.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep#resource-format)
- [ML - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/2023-04-01/workspaces?pivots=deployment-language-bicep)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary?view=azureml-api-2#compute)
- [AI + Machine Learning cost estimates](https://learn.microsoft.com/azure/well-architected/cost/provision-ai-ml)
