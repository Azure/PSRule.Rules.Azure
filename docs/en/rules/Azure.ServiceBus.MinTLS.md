---
reviewed: 2024-03-11
severity: Important
pillar: Security
category: SE:07 Encryption
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.MinTLS/
---

# Enforce namespaces to minimum use TLS 1.2 version

## SYNOPSIS

Service Bus namespaces should reject TLS versions older than 1.2.

## DESCRIPTION

Clients connect to Azure Service Bus to send and receive messages over a Transport Layer Security (TLS) encrypted connection.
The minimum version of TLS that Service Bus accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.
Additionally, support for TLS 1.0 and 1.1 are on a deprecation path across Azure services.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 are accepted.

When clients connect using an older version of TLS that is disabled, the connection will fail.

## RECOMMENDATION

Consider configuring the minimum supported TLS version for Service Bus clients to be 1.2.
Support for TLS 1.0/ 1.1 version will be removed.

## EXAMPLES

### Configure with Azure template

To deploy namespaces that pass this rule:

- Set the `properties.minimumTlsVersion` property to `1.2`.

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

- Set the `properties.minimumTlsVersion` property to `1.2`.

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

### Configure with Azure CLI

```bash
az servicebus namespace update -n '<name>' -g '<resource_group>' --minimum-tls-version '1.2'
```

### Configure with Azure PowerShell

```powershell
$ns = Get-AzServiceBusNamespace  -Name '<name>' -ResourceGroupName '<resource_group>'
Set-AzServiceBusNamespace -InputObject $ns -MinimumTlsVersion '1.2'
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/service-bus-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Enforce a minimum requires version of TLS](https://learn.microsoft.com/azure/service-bus-messaging/transport-layer-security-enforce-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicebus/namespaces)
