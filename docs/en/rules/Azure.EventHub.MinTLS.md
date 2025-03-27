---
reviewed: 2024-02-24
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Event Hub
resourceType: Microsoft.EventHub/namespaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.MinTLS/
---

# Event Hub Namespace accepts insecure TLS versions

## SYNOPSIS

Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities.

## DESCRIPTION

The minimum version of TLS that Event Hub namespaces accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

When clients connect using an older version of TLS that is disabled, the connection will fail.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2.
Also consider enforcing this setting using Azure Policy.

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

<!-- external:avm avm/res/event-hub/namespace minimumTlsVersion -->

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/event-hubs-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Enforce a minimum required version of Transport Layer Security (TLS) for requests to an Event Hubs namespace](https://learn.microsoft.com/azure/event-hubs/transport-layer-security-enforce-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces)
