---
severity: Important
pillar: Security
category: Security operations
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.Logs/
---

# Audit Key Vault data access

## SYNOPSIS

Audit and monitor access to Key Vault data.

## DESCRIPTION

To capture access to Key Vault data, diagnostic settings must be configured.
When configuring diagnostics settings enable access logs.

Management operations for Key Vault is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostic settings to log access for Key Vault data.
Also consider, storing the access data into Azure Monitor and using Key Vault Analytics.

## EXAMPLES

### Configure with Azure template

To deploy key vaults that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `AuditEvent` category.

For example:

```json
{
    "comments": "Create or update a Key Vault.",
    "type": "Microsoft.KeyVault/vaults",
    "name": "[parameters('vaultName')]",
    "apiVersion": "2019-09-01",
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
            "apiVersion": "2016-09-01",
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

## LINKS

- [Best practices to use Key Vault](https://docs.microsoft.com/azure/key-vault/general/best-practices)
- [Azure Key Vault logging](https://docs.microsoft.com/azure/key-vault/general/logging)
- [Azure Key Vault security](https://docs.microsoft.com/azure/key-vault/general/security-overview#logging-and-monitoring)
- [Monitoring your key vault service with Azure Monitor for Key Vault](https://docs.microsoft.com/azure/azure-monitor/insights/key-vault-insights-overview)
