---
reviewed: 2022-02-14
severity: Important
pillar: Security
category: Encryption
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.Insecure/
---

# Disable insecure container app ingress

## SYNOPSIS

Ensure insecure inbound traffic is not permitted to the container app.

## DESCRIPTION

Container Apps by default will automatically redirect any HTTP requests to HTTPS.
In this default configuration any inbound requests will occur over a minimum of TLS 1.2.
This secure by default behaviour can be overriden by allowing insecure HTTP traffic.

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
    "apiVersion": "2021-03-01",
    "name": "[parameters('appName')]",
    "location": "[parameters('location')]",
    "properties": {
        "kubeEnvironmentId": "[resourceId('Microsoft.Web/kubeEnvironments', parameters('envName'))]",
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
        "[resourceId('Microsoft.Web/kubeEnvironments', parameters('envName'))]"
    ]
}
```

### Configure with Bicep

To deploy resource that pass this rule:

- Set `properties.configuration.ingress.allowInsecure` to `false`.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2021-03-01' = {
  name: appName
  location: location
  properties: {
    kubeEnvironmentId: kubeEnv.id
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

## NOTES

Azure Container Apps are currently in preview.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Set up HTTPS ingress in Azure Container Apps](https://docs.microsoft.com/azure/container-apps/ingress#configuration)
- [Azure template reference](https://docs.microsoft.com/azure/container-apps/azure-resource-manager-api-spec)
