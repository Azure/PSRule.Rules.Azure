---
reviewed: 2023-08-20
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.Logs/
---

# Audit Key Vault Data Access

## SYNOPSIS

Ensure audit diagnostics logs are enabled to audit Key Vault access.

## DESCRIPTION

To capture logs that record interactions with data or the settings of key vault, diagnostic settings must be configured.

When configuring diagnostics settings, enable one of the following:

- `AuditEvent` category.
- `audit` category group.
- `allLogs` category group.

Management operations for Key Vault is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Configure audit diagnostics logs to audit Key Vault access.

## EXAMPLES

### Configure with Azure template

To deploy key vaults that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `AuditEvent` category or `audit` category group or `allLogs` category group.

For example:

```json
{
  "type": "Microsoft.KeyVault/vaults",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "family": "A",
      "name": "premium"
    },
    "tenantId": "[tenant().tenantId]",
    "softDeleteRetentionInDays": 90,
    "enableSoftDelete": true,
    "enablePurgeProtection": true,
    "enableRbacAuthorization": true,
    "networkAcls": {
      "defaultAction": "Deny",
      "bypass": "AzureServices"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Insights/diagnosticSettings",
      "apiVersion": "2021-05-01-preview",
      "scope": "[format('Microsoft.KeyVault/vaults/{0}', parameters('name'))]",
      "name": "logs",
      "properties": {
        "workspaceId": "[parameters('workspaceId')]",
        "logs": [
          {
            "category": "AuditEvent",
            "enabled": true
          }
        ]
      },
      "dependsOn": [
        "[parameters('name')]"
      ]
    }
  ]
}
```

### Configure with Bicep

To deploy key vaults that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `AuditEvent` category or `audit` category group or `allLogs` category group.

For example:

```bicep
resource vault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: tenant().tenantId
    softDeleteRetentionInDays: 90
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'logs'
  scope: vault
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}
```

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [LT-4: Enable logging for security investigation](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline#lt-4-enable-logging-for-security-investigation)
- [Best practices to use Key Vault](https://learn.microsoft.com/azure/key-vault/general/best-practices)
- [Azure Key Vault logging](https://learn.microsoft.com/azure/key-vault/general/logging)
- [Azure Key Vault security](https://learn.microsoft.com/azure/key-vault/general/security-features#logging-and-monitoring)
- [Monitoring your Key Vault service with Key Vault insights](https://learn.microsoft.com/azure/key-vault/key-vault-insights-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
