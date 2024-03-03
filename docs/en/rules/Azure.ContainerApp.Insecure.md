---
reviewed: 2024-03-04
severity: Important
pillar: Security
category: SE:07 Encryption
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
      "containers": "[variables('containers')]"
    },
    "configuration": {
      "ingress": {
        "allowInsecure": false,
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

To deploy resource that pass this rule:

- Set `properties.configuration.ingress.allowInsecure` to `false`.

For example:

```bicep
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

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Container Apps should only be accessible over HTTPS](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Apps/ContainerApps_EnableHTTPS_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/0e80e269-43a4-4ae9-b5bc-178126b8a5cb`

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Ingress in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/ingress-overview)
- [Container Apps ARM template API specification](https://learn.microsoft.com/azure/container-apps/azure-resource-manager-api-spec?tabs=arm-template)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
