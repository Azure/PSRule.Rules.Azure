---
reviewed: 2022-03-15
severity: Important
pillar: Security
category: Authentication
resource: SignalR Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SignalR.ManagedIdentity/
---

# Use managed identities for SignalR Services

## SYNOPSIS

Configure SignalR Services to use managed identities to access Azure resources securely.

## DESCRIPTION

A managed identity allows your service to access other Azure AD-protected resources such as Azure Functions.
The identity is managed by the Azure platform and doesn't require you to provision or rotate any secrets.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
  Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Azure AD authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each SignalR Service.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
    "type": "Microsoft.SignalRService/signalR",
    "apiVersion": "2021-10-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "kind": "SignalR",
    "sku": {
        "name": "Standard_S1"
    },
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "disableLocalAuth": true,
        "features": [
            {
                "flag": "ServiceMode",
                "value": "Serverless"
            }
        ]
    }
}
```

### Configure with Bicep

To deploy services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource service 'Microsoft.SignalRService/signalR@2021-10-01' = {
  name: name
  location: location
  kind: 'SignalR'
  sku: {
    name: 'Standard_S1'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
      }
    ]
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities for Azure SignalR Service](https://docs.microsoft.com/azure/azure-signalr/howto-use-managed-identity)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.signalrservice/signalr)
