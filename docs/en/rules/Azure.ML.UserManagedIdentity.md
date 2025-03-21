---
reviewed: 2023-10-13
severity: Important
pillar: Security
category: Identity and Access Management
resource: Machine Learning
resourceType: Microsoft.MachineLearningServices/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.UserManagedIdentity/
---

# Azure Machine Learning workspaces should use user-assigned managed identity

## SYNOPSIS

ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity.

## DESCRIPTION

Manage access to Azure ML workspace and associated resources, Azure Container Registry, KeyVault, Storage, and App Insights using user-assigned managed identity.
By default, system-assigned managed identity is used by Azure ML workspace to access the associated resources.
User-assigned managed identity allows you to create the identity as an Azure resource and maintain the life cycle of that identity.

## RECOMMENDATION

Consider using a User-Assigned Managed Identity, as part of a broader security and lifecycle management strategy.

## EXAMPLES

### Configure with Azure template

To deploy an ML - Workspace that passes this rule:

- Set the `identity.type` property to `UserAssigned`.
- Reference the identity with `identity.userAssignedIdentities`.
- Set the `properties.primaryUserAssignedIdentity` property value to the User-Assigned Managed Identity.

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
    "userAssignedIdentities": {
      "[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', 'example'))]": {}
    }
  },
  "properties": {
    "friendlyName": "[parameters('friendlyName')]",
    "keyVault": "[resourceId('Microsoft.KeyVault/vaults', 'example')]",
    "storageAccount": "[resourceId('Microsoft.Storage/storageAccounts', 'example')]",
    "applicationInsights": "[resourceId('Microsoft.Insights/components', 'example')]",
    "containerRegistry": "[resourceId('Microsoft.ContainerRegistry/registries', 'example')]",
    "publicNetworkAccess": "Disabled",
    "primaryUserAssignedIdentity": "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', 'example')]"
  }
}
```

### Configure with Bicep

To deploy an ML - Workspace that passes this rule:

- Set the `identity.type` property to `UserAssigned`.
- Reference the identity with `identity.userAssignedIdentities`.
- Set the `properties.primaryUserAssignedIdentity` property value to the User-Assigned Managed Identity.

For example:

```bicep
resource workspace 'Microsoft.MachineLearningServices/workspaces@2023-04-01' = {
  name: name
  location: location
  sku: {
    name: 'basic'
    tier: 'basic'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    friendlyName: friendlyName
    keyVault: keyVault.id
    storageAccount: storageAccount.id
    applicationInsights: appInsights.id
    containerRegistry: containerRegistry.id
    publicNetworkAccess: 'Disabled'
    primaryUserAssignedIdentity: identity.id
  }
}
```

## LINKS

- [WAF - Authentication with Azure AD](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Set up authentication between Azure Machine Learning and other services](https://learn.microsoft.com/azure/machine-learning/how-to-identity-based-service-authentication)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/baselines/machine-learning-service-security-baseline#im-3-manage-application-identities-securely-and-automatically)
- [Azure Policy Regulatory Compliance controls for Azure Machine Learning](https://learn.microsoft.com/azure/machine-learning/security-controls-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces#workspaceproperties)
