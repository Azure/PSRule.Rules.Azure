---
reviewed: 2024-03-11
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.DisableLocalAuth/
---

# Use identity-based authentication for Service Bus namespaces

## SYNOPSIS

Authenticate Service Bus publishers and consumers with Entra ID identities.

## DESCRIPTION

To publish or consume messages from Service Bus cryptographic keys, or Entra ID identities can be used.
Cryptographic keys include Shared Access Policy keys or Shared Access Signature (SAS) tokens.
With Entra ID authentication, the identity is validated against Entra ID.
Using Entra ID identities centralizes identity management and auditing.

Once you decide to use Entra ID authentication, you can disable authentication using keys or SAS tokens.

## RECOMMENDATION

Consider only using Entra ID identities to publish or consume messages from Service Bus.
Then disable authentication based on access keys or SAS tokens.

## EXAMPLES

### Configure with Azure template

To deploy namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.ServiceBus/namespaces",
  "apiVersion": "2022-10-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "Standard"
  },
  "properties": {
    "disableLocalAuth": true,
    "minimumTlsVersion": "1.2"
  }
}
```

### Configure with Bicep

To deploy namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource ns 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
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
    minimumTlsVersion: '1.2'
  }
}
```

<!-- external:avm avm/res/service-bus/namespace disableLocalAuth -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Service Bus namespaces should have local authentication methods disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Service%20Bus/ServiceBus_DisableLocalAuth_AuditDeny.json)
  `/providers/Microsoft.Authorization/policyDefinitions/cfb11c26-f069-4c14-8e36-56c394dae5af`
- [Configure Azure Service Bus namespaces to disable local authentication](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Service%20Bus/ServiceBus_DisableLocalAuth_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/910711a6-8aa2-4f15-ae62-1e5b2ed3ef9e`

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/service-bus-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Service Bus authentication and authorization](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-authentication-and-authorization)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicebus/namespaces)
