---
reviewed: 2024-04-15
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: SQL Database
resourceType: Microsoft.Sql/servers,Microsoft.Sql/servers/auditingSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.Auditing/
ms-content-id: d6084913-9ff9-40b6-a65b-30fcd4d49251
---

# Enable auditing for Azure SQL DB server

## SYNOPSIS

Enable auditing for Azure SQL logical server.

## DESCRIPTION

Auditing for Azure SQL Database tracks database events and writes them to an audit log.
Data collected from auditing can be used to help find suspicious events, unusual activity, and trends.

When managing security events at scale, it is important to have a centralized location to store and analyze security data.
A security information and event management (SIEM) system to consolidate security data in a central location.
Once the security data is in a central location it can be correlated across various services.
Security orchestration, automation, and response (SOAR) tools can be used to automate responses to security events.

Microsoft Sentinel is a scalable, cloud-native solution that provides:

- Security information and event management (SIEM).
- Security orchestration, automation, and response (SOAR).

## RECOMMENDATION

Consider enabling auditing for each SQL Database logical server and review reports on a regular basis.
Also consider enforcing this setting using Azure Policy.

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

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Auditing on SQL server should be enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/SQL/SqlServerAuditing_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9`
- [Configure SQL servers to have auditing enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/SQL/SqlServerAuditing_DINE.json)
  `/providers/Microsoft.Authorization/policyDefinitions/f4c68484-132f-41f9-9b6d-3e4b1cb55036`

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [LT-3: Enable logging for security investigation](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-sql-security-baseline#logging-and-threat-detection)
- [Auditing for Azure SQL Database and Azure Synapse Analytics](https://learn.microsoft.com/azure/azure-sql/database/auditing-overview)
- [What is Microsoft Sentinel?](https://learn.microsoft.com/azure/sentinel/overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/auditingsettings)
