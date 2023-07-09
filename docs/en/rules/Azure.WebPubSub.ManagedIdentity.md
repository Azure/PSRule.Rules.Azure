---
reviewed: 2022-03-15
severity: Important
pillar: Security
category: Authentication
resource: Web PubSub Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.WebPubSub.ManagedIdentity/
---

# Use managed identities for Web PubSub Services

## SYNOPSIS

Configure Web PubSub Services to use managed identities to access Azure resources securely.

## DESCRIPTION

A managed identity allows your service to access other Azure AD-protected resources such as Azure Functions.
The identity is managed by the Azure platform and doesn't require you to provision or rotate any secrets.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
  Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Azure AD authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each Web PubSub Service.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
    "type": "Microsoft.SignalRService/webPubSub",
    "apiVersion": "2021-10-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Standard_S1"
    },
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "disableLocalAuth": true
    }
}
```

### Configure with Bicep

To deploy services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource service 'Microsoft.SignalRService/webPubSub@2021-10-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_S1'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities for Azure Web PubSub Service](https://learn.microsoft.com/azure/azure-web-pubsub/howto-use-managed-identity)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-web-pubsub-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-web-pubsub-security-baseline#im-3-manage-application-identities-securely-and-automatically)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.signalrservice/webpubsub)
