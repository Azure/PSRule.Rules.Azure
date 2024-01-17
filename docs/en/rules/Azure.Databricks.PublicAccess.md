---
reviewed: 2024-01-12
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Databricks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Databricks.PublicAccess/
---

# Azure Databricks workspaces should disable public network access

## SYNOPSIS

Azure Databricks workspaces should disable public network access.

## DESCRIPTION

Disabling public network access improves security by ensuring that the resource isn't exposed on the public internet.
You can control exposure of your resources by creating private endpoints instead.

## RECOMMENDATION

Consider configuring Databricks workspaces to disable public network access, using private endpoints to control connectivity.

## EXAMPLES

### Configure with Azure template

To deploy workspaces that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

For example:

```json
{
  "type": "Microsoft.Databricks/workspaces",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "standard"
  },
  "properties": {
    "managedResourceGroupId": "[subscriptionResourceId('Microsoft.Resources/resourceGroups', 'example-mg')]",
    "publicNetworkAccess": "Disabled",
    "parameters": {
      "enableNoPublicIp": {
        "value": true
      }
    }
  }
}
```

### Configure with Bicep

To deploy workspaces that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

For example:

```bicep
resource databricks 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    managedResourceGroupId: managedRg.id
    publicNetworkAccess: 'Disabled'
    parameters: {
      enableNoPublicIp: {
        value: true
      }
    }
  }
}
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)  
- [Azure Databricks WorkspaceProperties](https://learn.microsoft.com/azure/templates/Microsoft.Databricks/workspaces?pivots=deployment-language-bicep#:~:text=WorkspaceCustomParameters-,publicNetworkAccess,-The%20network%20access)
- [Azure Databricks Private Link Overview](https://learn.microsoft.com/azure/databricks/security/network/classic/private-link)
- [Network access](https://learn.microsoft.com/azure/databricks/security/network/)
- [Azure Databricks architecture overview](https://learn.microsoft.com/azure/databricks/getting-started/overview)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.databricks/workspaces)
