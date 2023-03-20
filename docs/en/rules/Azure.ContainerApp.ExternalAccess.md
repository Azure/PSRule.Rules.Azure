---
severity: Important
pillar: Security
category: Network security and containment
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.ExternalAccess/
---

# Disable external access

## SYNOPSIS

Ensure inbound communication for Container Apps is limited to callers within the Container Apps environment.

## DESCRIPTION

Container apps allows you to expose your container app to the public web, to your VNET, or to other container apps within your environment by enabling ingress.

Container apps by default will automatically by default have visibility within app environment only if ingress is enabled.
This secure by default behaviour can be overriden by enabling visibility from internet or VNET, depending on app environment endpoint configured.

Disable external network access to container apps by enforcing internal-only ingress. This will ensure inbound communication for container apps is limited to callers within the container apps environment.

## RECOMMENDATION

Consider enforcing internal-only ingress.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.external` to `false`.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2022-10-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned",
    "userAssignedIdentities": {}
  },
  "properties": {
        "kubeEnvironmentId": "[resourceId('Microsoft.Web/kubeEnvironments', parameters('envName'))]",
        "template": {
            "revisionSuffix": "",
            "containers": "[variables('containers')]"
        },
        "configuration": {
            "ingress": {
                "external": false
            }
        }
    },
    "dependsOn": [
        "[resourceId('Microsoft.Web/kubeEnvironments', parameters('envName'))]"
    ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.external` to `false`.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
   properties: {
    kubeEnvironmentId: kubeEnv.id
    template: {
      revisionSuffix: ''
      containers: containers
    }
    configuration: {
      ingress: {
        external: false
      }
    }
  }
}
```

## LINKS

- [UNetworking architecture in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/networking)
- [Set up HTTPS or TCP ingress in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/ingress)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#ingress)
