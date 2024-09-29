---
reviewed: 2023-12-01
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
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

To deploy registries that pass this rule, consider:

- Configuring a `minLength` and `maxLength` constraint for the resource name parameter.
- Optionally, you could also use a `uniqueString()` function to generate a unique name.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 5,
      "maxLength": 50,
      "metadata": {
        "description": "The name of the resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerRegistry/registries",
      "apiVersion": "2023-08-01-preview",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Premium"
      },
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "adminUserEnabled": false,
        "policies": {
          "trustPolicy": {
            "status": "enabled",
            "type": "Notary"
          },
          "retentionPolicy": {
            "days": 30,
            "status": "enabled"
          }
        }
      }
    }
  ]
}
```

### Configure with Bicep

To deploy registries that pass this rule, consider:

- Configuring a `minLength` and `maxLength` constraint for the resource name parameter.
- Optionally, you could also use a `uniqueString()` function to generate a unique name.

For example:

```bicep
@minLength(5)
@maxLength(50)
@sys.description('The name of the resource.')
param name string

@sys.description('The location resources will be deployed.')
param location string = resourceGroup().location

resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
    }
  }
}
```

<!-- external:avm avm/res/container-registry/registry:0.5.1 name -->

## NOTES

This rule does not check if container registry names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
