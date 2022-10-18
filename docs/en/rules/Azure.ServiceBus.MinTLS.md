---
severity: Important
pillar: Security
category: Information protection
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.MinTLS/
---

# Enforce namespaces to minimum use TLS 1.2 version

## SYNOPSIS

Enforce namespaces to require that clients send and receive data with TLS 1.2 version.

## DESCRIPTION

Communication between a client application and an Azure Service Bus namespace is encrypted using Transport Layer Security (TLS).

Azure Service Bus namespaces permit clients to send and receive data with TLS 1.0 and above. To enforce stricter security measures, you can configure your Service Bus namespace to require that clients send and receive data with a newer version of TLS. If a Service Bus namespace requires a minimum version of TLS, then any requests made with an older version will fail.

**Important** If you are using a service that connects to Azure Service Bus, make sure that that service is using the appropriate version of TLS to send requests to Azure Service Bus before you set the required minimum version for a Service Bus namespace.

## RECOMMENDATION

Consider namespaces to require that clients send and receive data with TLS 1.2 version.

## EXAMPLES

### Configure with Azure template

To deploy Service Bus namespaces that pass this rule:

- Set `properties.minimumTlsVersion` to `1.2`.

For example:

```json
{
  "type": "Microsoft.ServiceBus/namespaces",
  "apiVersion": "2022-01-01-preview",
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

To deploy Service Bus namespaces that pass this rule:

- Set `properties.minimumTlsVersion` to `1.2`.

For example:

```bicep
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource ns 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
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

## LINKS

- [Information protection and storage](https://learn.microsoft.com/azure/architecture/framework/security/storage-data-encryption)
- [Enforce a minimum requires version of TLS](https://learn.microsoft.com/azure/service-bus-messaging/transport-layer-security-enforce-minimum-version)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.servicebus/namespaces)
