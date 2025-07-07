---
reviewed: 2025-03-28
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Event Grid Domain
resourceType: Microsoft.EventGrid/domains
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventGrid.DomainTLS/
---

# Event Grid Domain accepts insecure TLS versions

## SYNOPSIS

Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities.

## DESCRIPTION

The minimum version of TLS that Event Grid Domains accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

When clients connect using an older version of TLS that is disabled, the connection will fail.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2. Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Bicep

To deploy domains that pass this rule:

- Set the `properties.minimumTlsVersionAllowed` property to `1.2`.

For example:

```bicep
resource domain 'Microsoft.EventGrid/domains@2025-02-15' = {
  name: name
  location: location
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    minimumTlsVersionAllowed: '1.2'
    inputSchema: 'CloudEventSchemaV1_0'
  }
}
```

<!-- external:avm avm/res/event-grid/domain minimumTlsVersionAllowed -->

### Configure with Azure template

To deploy domains that pass this rule:

- Set the `properties.minimumTlsVersionAllowed` property to `1.2`.

For example:

```json
{
  "type": "Microsoft.EventGrid/domains",
  "apiVersion": "2025-02-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "disableLocalAuth": true,
    "publicNetworkAccess": "Disabled",
    "minimumTlsVersionAllowed": "1.2",
    "inputSchema": "CloudEventSchemaV1_0"
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Enforce a minimum required version of Transport Layer Security (TLS) for an Event Grid topic, domain, or subscription](https://learn.microsoft.com/azure/event-grid/transport-layer-security-enforce-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventgrid/domains)
