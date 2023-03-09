---
severity: Critical
pillar: Security
category: Encryption
resource: Event Hub
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.MinTLS/
---

# Minimum TLS version

## SYNOPSIS

Event Hub namespaces should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Event Hub namespaces accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.minimumlTlsVersion` property to `1.2`.

For example:

```json
{
  "type": "Microsoft.EventHub/namespaces",
  "apiVersion": "2022-01-01-preview",
  "name": "[parameters('eventHubNamespaceName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('eventHubSku')]",
    "tier": "[parameters('eventHubSku')]",
    "capacity": 1,
  },
  "properties": {
    "minimumTlsVersion": "1.2",
  }
}
```

### Configure with Bicep

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.minimumlTlsVersion` property to `1.2`.

For example:

```bicep
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Enforce a minimum required version of Transport Layer Security (TLS) for requests to an Event Hubs namespace](https://learn.microsoft.com/azure/event-hubs/transport-layer-security-enforce-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces)
