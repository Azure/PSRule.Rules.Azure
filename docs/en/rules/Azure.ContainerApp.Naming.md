---
reviewed: 2025-10-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Container App
resourceType: Microsoft.App/containerApps
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.Naming/
---

# Container App resources must use standard naming

## SYNOPSIS

Container App resources without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For Container App, the Cloud Adoption Framework (CAF) recommends using the `ca-` prefix.

Requirements for Container App resource names:

- Between 2 and 32 characters long.
- Can include alphanumeric characters, hyphens, underscores, and periods (restrictions vary by resource type).
- Resource names must be unique within their scope.

## RECOMMENDATION

Consider creating Container App resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(2)
@maxLength(32)
@description('The name of the container app.')
param appName string

resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
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
        external: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}
```

<!-- external:avm avm/res/app/container-app name -->

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

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
      "apiVersion": "2025-01-01",
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
            "external": false,
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

## NOTES

This rule does not check if Container App resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_CONTAINER_APP_NAME_FORMAT -->

To configure this rule set the `AZURE_CONTAINER_APP_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_CONTAINER_APP_NAME_FORMAT: '^ca-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence maturity model](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
