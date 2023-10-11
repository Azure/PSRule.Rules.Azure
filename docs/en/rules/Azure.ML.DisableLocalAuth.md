---
reviewed: 2023-10-10
severity: Critical
pillar: Security
category: Identity and Access Management
resource: ML
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.DisableLocalAuth/
---

# Name of rule

## SYNOPSIS

Azure Machine Learning compute resources should have local authentication methods disabled.

## DESCRIPTION

Disabling local authentication methods improves security by ensuring that Machine Learning Computes require Azure Active Directory identities exclusively for authentication. Learn more at: https://aka.ms/azure-ml-aad-policy.

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
      "managedResourceGroupId": "[subscriptionResourceId('Microsoft.Resources/resourceGroups', 'example-rg')]",
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
```

## LINKS

- [Disable local authentication](https://learn.microsoft.com/azure/machine-learning/how-to-integrate-azure-policy?view=azureml-api-2#disable-local-authentication)
- [ML - Compute objects](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep#resource-format)
- [ML - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/2023-04-01/workspaces?pivots=deployment-language-bicep)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary?view=azureml-api-2#compute)
- [Azure Policy Regulatory Compliance controls for Azure Machine Learning](https://learn.microsoft.com/azure/machine-learning/security-controls-policy?view=azureml-api-2)
- [WAF - Authentication with Azure AD](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
