---
reviewed: 2024-04-07
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Container App
resourceType: Microsoft.App/containerApps
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.ExternalIngress/
---

# Disable external ingress

## SYNOPSIS

Limit inbound communication for Container Apps is limited to callers within the Container Apps Environment.

## DESCRIPTION

Inbound access to a Container App is configured by enabling ingress.
Container Apps can be configured to allow external ingress or not.
External ingress permits communication outside the Container App environment from a private VNET or the Internet.
To restrict communication to a private VNET your Container App Environment must be:

- Configured with a custom VNET.
- Configured with an internal load balancer.

Applications that do batch processing or consume events may not require ingress to be enabled.
If communication outside your Container Apps Environment is not required, disable external ingress.

## RECOMMENDATION

Consider disabling external ingress.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.external` to `false`.

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

- Set `properties.configuration.ingress.external` to `false`.

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

<!-- external:avm avm/res/app/container-app:0.11.0 ingressExternal -->

## NOTES

This rule is skipped by default because there are common cases where external ingress is required.
If you don't need external ingress, enable this rule by:

- Setting the `AZURE_CONTAINERAPPS_RESTRICT_INGRESS` configuration option to `true`.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Networking in Azure Container Apps environment](https://learn.microsoft.com/azure/container-apps/networking)
- [Ingress in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/ingress-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#ingress)
