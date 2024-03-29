---
severity: Important
pillar: Security
category: Monitor
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.AuditLogs/
---

# Audit Service Bus data plane access

## SYNOPSIS

Ensure namespaces audit diagnostic logs are enabled.

## DESCRIPTION

To capture logs that record data plane access operations (such as send or receive messages) in the service bus, diagnostic settings must be configured.

When configuring diagnostic settings, enabled one of the following:

- `RuntimeAuditLogs` category.
- `audit` category group.
- `allLogs` category group.

Management operations for Service Bus is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostic settings to record interactions with data of the Service Bus.

## EXAMPLES

### Configure with Azure template

To deploy Service Bus namespaces that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `RuntimeAuditLogs` category or `audit` category group or `allLogs` category group.

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
    "name": "Premium"
  },
  "properties": {
    "disableLocalAuth": true,
    "minimumTlsVersion": "1.2"
  }
},
{
  "type": "Microsoft.Insights/diagnosticSettings",
  "apiVersion": "2021-05-01-preview",
  "scope": "[format('Microsoft.ServiceBus/namespaces/{0}', parameters('name'))]",
  "name": "[parameters('diagName')]",
  "properties": {
    "workspaceId": "[parameters('workspaceId')]",
    "logs": [
      {
        "category": "RuntimeAuditLogs",
        "enabled": true,
        "retentionPolicy": {
          "days": 0,
          "enabled": false
        }
      }
    ]
  },
  "dependsOn": [
    "[resourceId('Microsoft.ServiceBus/namespaces', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy Service Bus namespaces that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `RuntimeAuditLogs` category or `audit` category group or `allLogs` category group.

For example:

```bicep
resource ns 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
  }
}

resource nsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagName
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'RuntimeAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
  scope: ns
}
```

## NOTES

This rule only applies to premium tier Service Bus instances. Runtime audit logs are currently available only in the `Premium` tier.

## LINKS

- [Security audits](https://learn.microsoft.com/azure/architecture/framework/security/monitor-audit)
- [Monitoring Azure Service Bus data reference](https://learn.microsoft.com/azure/service-bus-messaging/monitor-service-bus-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
