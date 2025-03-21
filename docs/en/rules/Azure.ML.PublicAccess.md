---
reviewed: 2023-10-12
severity: Critical
pillar: Security
category: Connectivity
resource: Machine Learning
resourceType: Microsoft.MachineLearningServices/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.PublicAccess/
---

# ML Workspace has public access disabled

## SYNOPSIS

Disable public network access from a Azure Machine Learning workspace.

## DESCRIPTION

Disabling public network access improves security by ensuring that the Machine Learning Workspaces aren't exposed on the public internet.
You can control exposure of your workspaces by creating private endpoints instead.
By default, a public endpoint is enabled for Machine Learning workspaces.
The public endpoint is used for all access except for requests that use a Private Endpoint.
Access through the public endpoint can be disabled or restricted to authorized virtual networks.

Data exfiltration is an attack where an malicious actor does an unauthorized data transfer.
Private Endpoints help control exposure of a workspace to data exfiltration by an internal or external malicious actor.
They do this by providing clear separation between public and private endpoints.
As a result, broad access to public endpoints which could be operated by a malicious actor are not required.

## RECOMMENDATION

Consider disabling access from public endpoints by setting the `publicNetworkAccess` property to `Disabled` as part of a broader security strategy.

## EXAMPLES

### Configure with Azure template

To deploy an ML - Workspace that passes this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.
- If the `properties.allowPublicAccessWhenBehindVnet` property is defined remove the property.
  Switch to using the `properties.publicNetworkAccess` property instead.
  Configuring both properties is not required.

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
    "type": "SystemAssigned"
  },
  "properties": {
    "friendlyName": "[parameters('name')]",
    "keyVault": "[resourceId('Microsoft.KeyVault/vaults', parameters('KeyVaultName'))]",
    "storageAccount": "[resourceId('Microsoft.Storage/storageAccounts', parameters('StorageAccountName'))]",
    "applicationInsights": "[resourceId('Microsoft.Insights/components', parameters('AppInsightsName'))]",
    "containerRegistry": "[resourceId('Microsoft.ContainerRegistry/registries', parameters('ContainerRegistryName'))]",
    "publicNetworkAccess": "Disabled"
  }
}
```

### Configure with Bicep

To deploy an ML - Workspace that passes this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.
- If the `properties.allowPublicAccessWhenBehindVnet` property is defined remove the property.
  Switch to using the `properties.publicNetworkAccess` property instead.
  Configuring both properties is not required.

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

- [WAF - Azure services for securing network connectivity](https://learn.microsoft.com/azure/well-architected/security/design-network-connectivity)
- [Configure a private endpoint for an Azure Machine Learning workspace](https://learn.microsoft.com/azure/machine-learning/how-to-configure-private-link?view=azureml-api-2&tabs=cli)
- [ML - Public access to Workspaces](https://learn.microsoft.com/azure/machine-learning/how-to-secure-workspace-vnet?view=azureml-api-2&tabs=required%2Cpe%2Ccli#public-access-to-workspace)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/machine-learning-service-security-baseline#ns-2-secure-cloud-services-with-network-controls)
- [Security and governance for ML](https://learn.microsoft.com/azure/machine-learning/concept-enterprise-security?view=azureml-api-2)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces?pivots=deployment-language-bicep#workspaceproperties)
