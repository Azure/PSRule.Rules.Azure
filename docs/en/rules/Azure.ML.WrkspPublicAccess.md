---
reviewed: 2023-10-12
severity: Critical
pillar: Security
category: Networking
resource: ML
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.WrkspPublicAccess/
---

# ML Workspace has public access disabled

## SYNOPSIS

Disable public network access from a ML - Workspace. 

## DESCRIPTION

Disabling public network access improves security by ensuring that the Machine Learning Workspaces aren't exposed on the public internet. You can control exposure of your workspaces by creating private endpoints instead. 

## RECOMMENDATION

Consider setting the 'publicNetworkAccess' parameter of the Workspace properties to "Disabled", as part of a broader security strategy. 

## EXAMPLES

### Configure with Azure template

To deploy an ML - Workspace that complies with this rule:

- update the 'publicNetworkAccess' parameter of the Workspace properties to "Disabled".

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

```

### Configure with Bicep

To deploy an ML - Workspace that complies with this rule:

- update the 'publicNetworkAccess' parameter of the Workspace properties to 'Disabled'.

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
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: friendlyName
    keyVault: KeyVault.id
    storageAccount: StorageAccount.id
    applicationInsights: AppInsights.id
    containerRegistry: ContainerRegistry.id
    publicNetworkAccess: 'Disabled'
  }
}

```

## LINKS

- [Configure a private endpoint for an Azure Machine Learning workspace](https://learn.microsoft.com/azure/machine-learning/how-to-configure-private-link?view=azureml-api-2&tabs=cli)
- [ML - Public access to Workspaces](https://learn.microsoft.com/azure/machine-learning/how-to-secure-workspace-vnet?view=azureml-api-2&tabs=required%2Cpe%2Ccli#public-access-to-workspace)
- [ML - Workspaces](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces?pivots=deployment-language-bicep#workspaceproperties)
- [Security and governance for ML](https://learn.microsoft.com/azure/machine-learning/concept-enterprise-security?view=azureml-api-2)
- [WAF - Azure services for securing network connectivity](https://learn.microsoft.com/azure/well-architected/security/design-network-connectivity)