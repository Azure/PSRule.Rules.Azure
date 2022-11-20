---
severity: Important
pillar: Security
category: Security operations
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
    "comments": "Create or update a Key Vault.",
    "type": "Microsoft.KeyVault/vaults",
    "name": "[parameters('vaultName')]",
    "apiVersion": "2022-07-01",
    "location": "[parameters('location')]",
    "properties": {
        "accessPolicies": [],
        "tenantId": "[subscription().tenantId]",
        "sku": {
            "name": "Standard",
            "family": "A"
        }
    },
    "resources": [
        {
            "comments": "Enable monitoring of Key Vault operations.",
            "type": "Microsoft.KeyVault/vaults/providers/diagnosticSettings",
            "name": "[concat(parameters('vaultName'), '/Microsoft.Insights/service')]",
            "apiVersion": "2021-05-01-preview",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.KeyVault/vaults/', parameters('vaultName'))]"
            ],
            "properties": {
                "workspaceId": "[parameters('workspaceId')]",
                "logs": [
                    {
                        "category": "AuditEvent",
                        "enabled": true
                    }
                ]
            }
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
resource keyVaultResource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: parmVaultName
  location: parmLocation
  properties: {
    accessPolicies: []
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultInsightsResource 'Microsoft.KeyVault/vaults/providers/diagnosticSettings@2022-05-01-preview' = {
  name: '${parmVaultName}/Microsoft.Insights/service'
  dependsOn: [
    keyVaultResource
  ]
  location: parmLocation
  properties: {
    workspaceId: parmWorkspaceId
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

- [Security logs and alerts using Azure services](https://learn.microsoft.com/azure/architecture/framework/security/monitor-logs-alerts)
- [Best practices to use Key Vault](https://learn.microsoft.com/azure/key-vault/general/best-practices)
- [Azure Key Vault logging](hhttps://learn.microsoft.com/azure/key-vault/general/logging)
- [Azure Key Vault security](https://learn.microsoft.com/azure/key-vault/general/security-features#logging-and-monitoring)
- [Monitoring your Key Vault service with Key Vault insights](https://learn.microsoft.com/azure/key-vault/key-vault-insights-overview)
- [Template Reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
