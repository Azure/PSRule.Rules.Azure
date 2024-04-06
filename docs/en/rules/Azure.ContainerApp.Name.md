---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.Name/
---

# Use valid container app names

## SYNOPSIS

Container Apps should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for container app names are:

- Between 2 and 32 characters long.
- Lowercase letters, numbers, and hyphens.
- Start with letter and end with alphanumeric.

## RECOMMENDATION

Consider using container app names that meets naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Configuring a `minLength` and `maxLength` constraint for the resource name parameter.
- Optionally, you could also use a `uniqueString()` function to generate a unique name.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "envName": {
      "type": "string",
      "metadata": {
        "description": "The name of the app environment."
      }
    },
    "appName": {
      "type": "string",
      "minLength": 2,
      "maxLength": 32,
      "metadata": {
        "description": "The name of the container app."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    },
    "workspaceId": {
      "type": "string",
      "metadata": {
        "description": "The name of a Log Analytics workspace"
      }
    },
    "subnetId": {
      "type": "string",
      "metadata": {
        "description": "The resource ID of a VNET subnet."
      }
    },
    "revision": {
      "type": "string",
      "metadata": {
        "description": "The revision of the container app."
      }
    }
  },
  "variables": {
    "containers": [
      {
        "name": "simple-hello-world-container",
        "image": "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest",
        "resources": {
          "cpu": "[json('0.25')]",
          "memory": ".5Gi"
        }
      }
    ]
  },
  "resources": [
    {
      "type": "Microsoft.App/containerApps",
      "apiVersion": "2023-05-01",
      "name": "[parameters('appName')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "environmentId": "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]",
        "template": {
          "revisionSuffix": "[parameters('revision')]",
          "containers": "[variables('containers')]",
          "scale": {
            "minReplicas": 2
          }
        },
        "configuration": {
          "ingress": {
            "allowInsecure": false,
            "stickySessions": {
              "affinity": "none"
            }
          }
        }
      }
    }
  ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Configuring a `minLength` and `maxLength` constraint for the resource name parameter.
- Optionally, you could also use a `uniqueString()` function to generate a unique name.

For example:

```bicep
@minLength(2)
@maxLength(32)
@description('The name of the container app.')
param appName string

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerEnv.id
    template: {
      revisionSuffix: revision
      containers: containers
      scale: {
        minReplicas: 2
      }
    }
    configuration: {
      ingress: {
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}
```

## NOTES

This rule does not check if container app names are unique.

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Naming rules and restrictions for container app resource](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftapp)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
