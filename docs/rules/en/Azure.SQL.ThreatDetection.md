---
severity: Important
pillar: Security
category: Security operations
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.ThreatDetection.md
ms-content-id: 720e560d-4ad3-41ca-93dd-69c5783b9dbe
---

# Use Advanced Threat Protection

## SYNOPSIS

Enable Advanced Thread Protection for Azure SQL logical server.

## DESCRIPTION

Enable Advanced Thread Protection for Azure SQL logical server.

## RECOMMENDATION

Consider enabling Advanced Data Security and configuring Advanced Thread Protection for SQL logical servers.

## EXAMPLES

### Configure with Azure template

```json
{
    "comments": "Create or update an Azure SQL logical server.",
    "type": "Microsoft.Sql/servers",
    "apiVersion": "2019-06-01-preview",
    "name": "[parameters('serverName')]",
    "location": "[parameters('location')]",
    "tags": "[parameters('tags')]",
    "kind": "v12.0",
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "administratorLogin": "[parameters('adminUsername')]",
        "version": "12.0",
        "publicNetworkAccess": "[if(parameters('allowPublicAccess'), 'Enabled', 'Disabled')]",
        "administratorLoginPassword": "[parameters('adminPassword')]",
        "minimalTLSVersion": "1.2"
    },
    "resources": [
        {
            "type": "Microsoft.Sql/servers/securityAlertPolicies",
            "apiVersion": "2020-02-02-preview",
            "name": "[concat(parameters('serverName'), '/Default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
            ],
            "properties": {
                "state": "Enabled"
            }
        }
    ]
}
```

### Configure with Azure PowerShell

```powershell
Set-AzSqlDatabaseThreatDetectionPolicy -ResourceGroupName '<resource_group>' -ServerName '<server_name>' -DatabaseName '<database>' -StorageAccountName '<account_name>' -NotificationRecipientsEmails '<email>' -EmailAdmins $False
```

## LINKS

- [Advanced Threat Protection for Azure SQL Database](https://docs.microsoft.com/azure/sql-database/sql-database-threat-detection-overview)
- [Advanced data security for Azure SQL Database](https://docs.microsoft.com/azure/sql-database/sql-database-advanced-data-security)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers/securityalertpolicies)
