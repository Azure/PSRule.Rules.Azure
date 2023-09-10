---
reviewed: 2022/01/22
severity: Important
pillar: Security
category: Authentication
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.DisableLocalAuth/
---

# Use identity-based authentication for Service Bus namespaces

## SYNOPSIS

Authenticate Service Bus publishers and consumers with Azure AD identities.

## DESCRIPTION

To publish or consume messages from Service Bus cryptographic keys, or Azure AD identities can be used.
Cryptographic keys include Shared Access Policy keys or Shared Access Signature (SAS) tokens.
With Azure AD authentication, the identity is validated against Azure AD.
Using Azure AD identities centralizes identity management and auditing.

Once you decide to use Azure AD authentication, you can disable authentication using keys or SAS tokens.

## RECOMMENDATION

Consider only using Azure AD identities to publish or consume messages from Service Bus.
Then disable authentication based on access keys or SAS tokens.

## EXAMPLES

### Configure with Azure template

To deploy Service Bus namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
    "type": "Microsoft.ServiceBus/namespaces",
    "apiVersion": "2021-11-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "SystemAssigned"
    },
    "sku": {
        "name": "Standard"
    },
    "properties": {
        "disableLocalAuth": true
    }
}
```

### Configure with Bicep

To deploy Service Bus namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource ns 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    disableLocalAuth: true
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Service Bus authentication and authorization](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-authentication-and-authorization)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.servicebus/namespaces)
