---
reviewed: 2024-09-29
severity: Important
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.APIVersion/
---

# Retired API version

## SYNOPSIS

Migrate from retired API version to a supported version.

## DESCRIPTION

The API Azure Container Apps control plane API versions `2022-06-01-preview` and `2022-11-01-preview` are deprecated.
These API versions will be retired on the November 16, 2023.

This means you'll no longer be able to create or update your Azure Container Apps using your existing templates,
tools, scripts and programs until they've been updated to a supported API version.

## RECOMMENDATION

Consider migrating from a retired API version to a newer supported version by updating your Infrastructure as Code.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `apiVersion` to a newer supported version such as `2024-03-01`.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2024-03-01",
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
        "ipSecurityRestrictions": "[variables('ipSecurityRestrictions')]",
        "stickySessions": {
          "affinity": "none"
        }
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]"
  ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set `apiVersion` to a newer supported version such as `2024-03-01`.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
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
        ipSecurityRestrictions: ipSecurityRestrictions
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}
```

<!-- external:avm avm/res/app/container-app:0.11.0 -->

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Azure Container Apps API versions retirements](https://azure.microsoft.com/updates/retirement-azure-container-apps-preview-api-versions-20220601preview-and-20221101preview)
- [Azure Container Apps latest API versions](https://learn.microsoft.com/azure/container-apps/azure-resource-manager-api-spec)
- [Azure Container Apps API change log](https://learn.microsoft.com/azure/templates/microsoft.app/change-log/summary)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
