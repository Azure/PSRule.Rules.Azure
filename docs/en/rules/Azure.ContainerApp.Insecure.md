---
reviewed: 2023-04-29
severity: Important
pillar: Security
category: Design
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.Insecure/
---

# Disable insecure container app ingress

## SYNOPSIS

Ensure insecure inbound traffic is not permitted to the container app.

## DESCRIPTION

Container Apps by default will automatically redirect any HTTP requests to HTTPS.
In this default configuration any inbound requests will occur over a minimum of TLS 1.2.
This secure by default behavior can be overridden by allowing insecure HTTP traffic.

Unencrypted communication to Container Apps could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Consider disabling insecure traffic and require all inbound traffic to be over TLS 1.2.

## EXAMPLES

### Configure with Azure template

To deploy resource that pass this rule:

- Set `properties.configuration.ingress.allowInsecure` to `false`.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2022-10-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "properties": {
    "managedEnvironmentId": "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]",
    "template": {
      "revisionSuffix": "",
      "containers": "[variables('containers')]"
    },
    "configuration": {
      "ingress": {
        "allowInsecure": false
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]"
  ]
}
```

### Configure with Bicep

To deploy resource that pass this rule:

- Set `properties.configuration.ingress.allowInsecure` to `false`.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: containerEnv.id
    template: {
      revisionSuffix: ''
      containers: containers
    }
    configuration: {
      ingress: {
        allowInsecure: false
      }
    }
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Ingress in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/ingress-overview#configuration)
- [Container Apps ARM template API specification](https://learn.microsoft.com/azure/container-apps/azure-resource-manager-api-spec?tabs=arm-template)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
