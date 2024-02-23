---
reviewed: 2024-02-24
severity: Critical
pillar: Security
category: SE:07 Encryption
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

- Set the `properties.minimumTlsVersion` property to `1.2`.

For example:

```json
{
  "type": "Microsoft.EventHub/namespaces",
  "apiVersion": "2024-01-01",
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
    "minimumTlsVersion": "1.2",
    "publicNetworkAccess": "Disabled",
    "isAutoInflateEnabled": true,
    "maximumThroughputUnits": 10,
    "zoneRedundant": true
  }
}
```

### Configure with Bicep

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.minimumTlsVersion` property to `1.2`.

For example:

```bicep
resource ns 'Microsoft.EventHub/namespaces@2024-01-01' = {
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
    publicNetworkAccess: 'Disabled'
    isAutoInflateEnabled: true
    maximumThroughputUnits: 10
    zoneRedundant: true
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Enforce a minimum required version of Transport Layer Security (TLS) for requests to an Event Hubs namespace](https://learn.microsoft.com/azure/event-hubs/transport-layer-security-enforce-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces)
