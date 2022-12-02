---
severity: Important
pillar: Security
category: Security operations
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.Auditing/
ms-content-id: d6084913-9ff9-40b6-a65b-30fcd4d49251
---

# Enable auditing for Azure SQL DB server

## SYNOPSIS

Enable auditing for Azure SQL logical server.

## DESCRIPTION

Auditing for Azure SQL Database tracks database events and writes them to an audit log.
Audit logs help you find suspicious events, unusual activity, and trends.

## RECOMMENDATION

Consider enabling auditing for each SQL Database logical server and review reports on a regular basis.

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
            "type": "Microsoft.Sql/servers/auditingPolicies",
            "apiVersion": "2014-04-01",
            "name": "[concat(parameters('serverName'), '/Default')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
            ],
            "properties": {
                "auditingState": "Enabled"
            }
        },
        {
            "type": "Microsoft.Sql/servers/auditingSettings",
            "apiVersion": "2017-03-01-preview",
            "name": "[concat(parameters('serverName'), '/Default')]",
            "dependsOn": [
                "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
            ],
            "properties": {
                "state": "Enabled",
                "retentionDays": 7,
                "auditActionsAndGroups": [
                    "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP",
                    "FAILED_DATABASE_AUTHENTICATION_GROUP",
                    "BATCH_COMPLETED_GROUP"
                ],
                "storageAccountSubscriptionId": "[split(parameters('securityStorageAccountId'), '/')[2]]",
                "isStorageSecondaryKeyInUse": false,
                "isAzureMonitorTargetEnabled": false,
                "storageEndpoint": "[reference(parameters('securityStorageAccountId'),'2019-06-01').primaryendpoints.blob]",
                "storageAccountAccessKey": "[listKeys(parameters('securityStorageAccountId'),'2019-06-01').keys[0].value]"
            }
        }
    ]
}
```

### Configure with Azure CLI

```bash
az sql server audit-policy update -g '<resource_group>' -n '<server_name>' --state Enabled --bsts Enabled --storage-account '<storage_account_name>'
```

### Configure with Azure PowerShell

```powershell

Set-AzSqlServerAudit -ResourceGroupName '<resource_group>' -ServerName '<server_name>' -BlobStorageTargetState Enabled -StorageAccountResourceId '<storage_resource_id>'
```

## LINKS

- [Auditing for Azure SQL Database and Azure Synapse Analytics](https://docs.microsoft.com/azure/azure-sql/database/auditing-overview)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers/auditingsettings)
