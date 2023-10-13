---
reviewed: 2022-10-13
severity: Important
pillar: Security
category: Identity and Access Management
resource: ML
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/WrkspUserMgId/
---

# Azure Machine Learning workspaces should use user-assigned managed identity

## SYNOPSIS

ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity.  

## DESCRIPTION

Manange access to Azure ML workspace and associated resources, Azure Container Registry, KeyVault, Storage, and App Insights using user-assigned managed identity. By default, system-assigned managed identity is used by Azure ML workspace to access the associated resources. User-assigned managed identity allows you to create the identity as an Azure resource and maintain the life cycle of that identity.

## RECOMMENDATION

ML - Compute should be configured to use a user-assigned managed identity, as part of a broader security and lifecycle management strategy. 

## EXAMPLES

### Configure with Azure template

To deploy an ML - Workspace that complies with this rule:

- Set the `identity` section;
    - Change `Type` to "UserAssigned"
    - Add in the 'userAssignedIdentities' field with the Managed Identity reference
- Set the `primaryUserAssignedIdentity` property value to the User Assigned Managed Identity

For example:

```json

{
    "type": "Microsoft.MachineLearningServices/workspaces",
    "apiVersion": "2023-04-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "sku": {
      "name": "basic",
      "tier": "basic"
    },
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {"subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/UserAssignedManagedIdentity": {}
        }
    },
    "properties": {
      "friendlyName": "[parameters('name')]",
      "keyVault": "[resourceId('Microsoft.KeyVault/vaults', parameters('KeyVaultName'))]",
      "storageAccount": "[resourceId('Microsoft.Storage/storageAccounts', parameters('StorageAccountName'))]",
      "applicationInsights": "[resourceId('Microsoft.Insights/components', parameters('AppInsightsName'))]",
      "containerRegistry": "[resourceId('Microsoft.ContainerRegistry/registries', parameters('ContainerRegistryName'))]",
      "primaryUserAssignedIdentity": "[parameters('UserAssignedManagedIdentity')]"
    }
}
```

### Configure with Bicep

To deploy an ML - Workspace that complies with this rule:

- Set the `identity` section;
    - Change `Type` to "UserAssigned"
    - Add in the 'userAssignedIdentities' field with the Managed Identity reference
- Set the `primaryUserAssignedIdentity` property value to the User Assigned Managed Identity

For example:

```bicep

resource Ml_Workspace 'Microsoft.MachineLearningServices/workspaces@2023-04-01' = {
  name: name
  location: location
  sku: {
    name: 'basic'
    tier: 'basic'
  }
  identity: {
    type: 'UserAssigned', 
    "userAssignedIdentities": {
      UserAssignedManagedIdentity.id: {}
      }
  },
  properties: {
    friendlyName: friendlyName
    keyVault: KeyVault.id
    storageAccount: StorageAccount.id
    applicationInsights: AppInsights.id
    containerRegistry: ContainerRegistry.id
    primaryUserAssignedIdentity: UserAssignedManagedIdentity
  }
}
```


## LINKS

- [Set up authentication between Azure Machine Learning and other services](https://learn.microsoft.com/azure/machine-learning/how-to-identity-based-service-authentication?view=azureml-api-2&tabs=python)
- [ML - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces?pivots=deployment-language-bicep#workspaceproperties)
- [Azure Policy Regulatory Compliance controls for Azure Machine Learning](https://learn.microsoft.com/azure/machine-learning/security-controls-policy?view=azureml-api-2)
- [WAF - Authentication with Azure AD](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)

