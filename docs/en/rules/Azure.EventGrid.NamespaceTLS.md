---
reviewed: 2025-07-07
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Event Grid Namespace
resourceType: Microsoft.EventGrid/namespaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventGrid.NamespaceTLS/
---

# Event Grid Namespace accepts insecure TLS versions

## SYNOPSIS

Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities.

## DESCRIPTION

The minimum version of TLS that Event Grid Namespaces accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

When clients connect using an older version of TLS that is disabled, the connection will fail.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2. Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Bicep

To deploy namespaces that pass this rule:

- Set the `properties.minimumTlsVersionAllowed` property to `1.2`.

For example:

```bicep
resource namespace 'Microsoft.EventGrid/namespaces@2025-02-15' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimumTlsVersionAllowed: '1.2'
    isZoneRedundant: true
  }
}
```

### Configure with Azure template

To deploy namespaces that pass this rule:

- Set the `properties.minimumTlsVersionAllowed` property to `1.2`.

For example:

```json
{
  "type": "Microsoft.EventGrid/namespaces",
  "apiVersion": "2025-02-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "publicNetworkAccess": "Disabled",
    "minimumTlsVersionAllowed": "1.2",
    "isZoneRedundant": true
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventgrid/namespaces)
