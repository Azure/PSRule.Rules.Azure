---
severity: Important
pillar: Security
category: Network security and containment
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.ExternalIngress/
---

# Disable external ingress

## SYNOPSIS

Limit inbound communication for Container Apps is limited to callers within the Container Apps Environment.

## DESCRIPTION

Container apps allows you to expose your container app to the Internet, your VNET, or to other container apps within the same environment by enabling ingress.

When inbound access to the app is required, configure the ingress.
Applications that do batch processing or consume events may not require ingress to be enabled.

When external ingress is configured, communication outside the container apps environment is enabled from your private VNET or the Internet.
To restrict communication to a private VNET your Container App Environment must be deployed on a custom VNET with an Internal load balancer.

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
  "apiVersion": "2022-10-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned",
    "userAssignedIdentities": {}
  },
  "properties": {
        "environmentId": "[parameters('environmentId')]",
        "template": {
            "revisionSuffix": "",
            "containers": "[variables('containers')]"
        },
        "configuration": {
            "ingress": {
                "external": false
            }
        }
    }
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
    environmentId: environmentId
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

## NOTES

This rule is skipped by default because there are common cases where external ingress is required.
If you don't need external ingress, enable this rule by:

- Setting the `AZURE_CONTAINERAPPS_RESTRICT_INGRESS` configuration option to `true`.

## LINKS

- [Networking architecture in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/networking)
- [Set up HTTPS or TCP ingress in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/ingress)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#ingress)
