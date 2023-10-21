---
reviewed: 2023-10-10
severity: Critical
pillar: Security
category: Authentication
resource: Machine Learning
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.DisableLocalAuth/
---

# Disable local authentication on ML Compute

## SYNOPSIS

Azure Machine Learning compute resources should have local authentication methods disabled.

## DESCRIPTION

Azure Machine Learning (ML) compute can have local authenication enabled or disabled.
When enabled local authentication methods must be managed and audited separately.

Disabling local authentication ensures that Entra ID (previously Azure Active Directory) is used exclusively for authentication.
Using Entra ID, provides consistency as a single authoritative source which:

- Increases clarity and reduces security risks from human errors and configuration complexity.
- Provides support for advanced identity security and governance features.

## RECOMMENDATION

Consider disabling local authentication on ML - Compute as part of a broader security strategy.

## EXAMPLES

### Configure with Azure template

To deploy ML - compute that passes this rule:

- Set the `properties.disableLocalAuth` property to `true`.

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

To deploy ML - compute that passes this rule:

- Set the `properties.disableLocalAuth` property to `true`.

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

- [WAF - Authentication with Azure AD](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Disable local authentication](https://learn.microsoft.com/azure/machine-learning/how-to-integrate-azure-policy#disable-local-authentication)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary#compute)
- [Azure Policy Regulatory Compliance controls for Azure Machine Learning](https://learn.microsoft.com/azure/machine-learning/security-controls-policy)
- [Azure deployment reference - Compute objects](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces/computes#compute-objects)
- [Azure deployment reference - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces)
