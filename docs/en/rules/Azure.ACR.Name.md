---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Name/
---

# Use valid registry names

## SYNOPSIS

Container registry names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for container registry names are:

- Between 5 and 50 characters long.
- Alphanumerics.
- Container registry names must be globally unique.

## RECOMMENDATION

Consider using names that meet container registry naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

You could ensure that `acrName` parameter meets naming requirements by using `MinLength` and `maxLength` parameter properties.
You could also use a `uniqueString()` function to ensure the name is globally unique.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "acrName": {
      "type": "string",
      "defaultValue": "[format('acr{0}', uniqueString(resourceGroup().id))]",
      "maxLength": 50,
      "minLength": 5,
      "metadata": {
        "description": "Globally unique name of your Azure Container Registry"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for registry home replica."
      }
    },
    "acrSku": {
      "type": "string",
      "defaultValue": "Premium",
      "allowedValues": [
        "Standard"
        "Premium"
      ],
      "metadata": {
        "description": "Tier of your Azure Container Registry."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerRegistry/registries",
      "apiVersion": "2019-12-01-preview",
      "name": "[parameters('acrName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "[parameters('acrSku')]"
      },
      "tags": {
        "displayName": "Container Registry",
        "container.registry": "[parameters('acrName')]"
      }
    }
  ],
  "outputs": {
    "acrLoginServer": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))).loginServer]"
    }
  }
}
```

### Configure with Bicep

You could ensure that `acrName` parameter meets naming requirements by using `@MinLength` and `@maxLength` parameter decorators.
You could also use a `uniqueString()` function to ensure the name is globally unique.

For example:

```bicep
@description('Globally unique name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Location for registry home replica.')
param location string = resourceGroup().location

@description('Tier of your Azure Container Registry. Geo-replication requires Premium SKU.')
@allowed([
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
}

output acrLoginServer string = containerRegistry.properties.loginServer
```

## NOTES

This rule does not check if container registry names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
