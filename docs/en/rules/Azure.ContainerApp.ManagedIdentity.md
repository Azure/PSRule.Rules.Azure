---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.ManagedIdentity/
---

# Use managed identity for authentication

## SYNOPSIS

Ensure managed identity is used for authentication.

## DESCRIPTION

Using managed identities have the following benefits:

- Your app connects to resources with the managed identity.
  You don't need to manage credentials in your container app.
- You can use role-based access control to grant specific permissions to a managed identity.
- System-assigned identities are automatically created and managed.
  They're deleted when your container app is deleted.
- You can add and delete user-assigned identities and assign them to multiple resources.
  They're independent of your container app's life cycle.
- You can use managed identity to authenticate with a private Azure Container Registry without a username and password to pull containers for your Container App.
- You can use managed identity to create connections for Dapr-enabled applications via Dapr components.

## RECOMMENDATION

Consider configure a managed identity for each container app.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned` or `SystemAssigned,UserAssigned`.
- If `identity.type` is `UserAssigned` or `SystemAssigned,UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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
  },
  "dependsOn": [
    "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]"
  ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned` or `SystemAssigned,UserAssigned`.
- If `identity.type` is `UserAssigned` or `SystemAssigned,UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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

<!-- external:avm avm/res/app/container-app managedIdentities -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Managed Identity should be enabled for Container Apps](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Apps/ContainerApps_ManagedIdentity_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/b874ab2d-72dd-47f1-8cb5-4a306478a4e7`

## NOTES

Using managed identities in scale rules isn't supported.
Init containers can't access managed identities.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Managed identities in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/managed-identity)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#managedserviceidentity)
