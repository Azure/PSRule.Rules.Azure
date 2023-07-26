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

To deploy logical servers that pass this rule:

- Define a `Microsoft.Sql/servers/auditingSettings` sub-resource with each logical server.
- Set the `properties.state` property to `Enabled` for the `Microsoft.Sql/servers/auditingSettings` sub-resource.

For example:

```json
{
  "type": "Microsoft.Sql/servers/auditingSettings",
  "apiVersion": "2022-08-01-preview",
  "name": "[format('{0}/{1}', parameters('name'), 'default')]",
  "properties": {
    "isAzureMonitorTargetEnabled": true,
    "state": "Enabled",
    "retentionDays": 7,
    "auditActionsAndGroups": [
      "SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP",
      "FAILED_DATABASE_AUTHENTICATION_GROUP",
      "BATCH_COMPLETED_GROUP"
    ]
  },
  "dependsOn": [
    "server"
  ]
}
```

### Configure with Bicep

To deploy logical servers that pass this rule:

- Define a `Microsoft.Sql/servers/auditingSettings` sub-resource with each logical server.
- Set the `properties.state` property to `Enabled` for the `Microsoft.Sql/servers/auditingSettings` sub-resource.

For example:

```bicep
resource server 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: adminLogin
      principalType: 'Group'
      sid: adminPrincipalId
      tenantId: tenant().tenantId
    }
  }
}

resource sqlAuditSettings 'Microsoft.Sql/servers/auditingSettings@2022-08-01-preview' = {
  name: 'default'
  parent: server
  properties: {
    isAzureMonitorTargetEnabled: true
    state: 'Enabled'
    retentionDays: 7
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
  }
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
