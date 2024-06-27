---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.TDE/
---

# Use SQL database TDE

## SYNOPSIS

Use Transparent Data Encryption (TDE) with Azure SQL Database.

## DESCRIPTION

TDE helps protect Azure SQL Databases against malicious offline access by encrypting data at rest.
SQL Databases perform real-time encryption and decryption of the database, backups, and log files.
Encryption is perform at rest without requiring changes to the application.

By default, TDE is enabled for all user-defined databases.

## RECOMMENDATION

Consider enabling Transparent Data Encryption (TDE) for Azure SQL Databases to perform encryption at rest.

## EXAMPLES

### Configure with Azure template

To deploy databases that pass this rule:

- Configure a `Microsoft.Sql/servers/databases/transparentDataEncryption` sub-resource.
  - Set the `properties.state` to `Enabled`.

For example:

```json
{
  "type": "Microsoft.Sql/servers/databases/transparentDataEncryption",
  "apiVersion": "2023-08-01-preview",
  "name": "[format('{0}/{1}/{2}', parameters('name'), parameters('name'), 'current')]",
  "properties": {
    "state": "Enabled"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/servers/databases', parameters('name'), parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy databases that pass this rule:

- Configure a `Microsoft.Sql/servers/databases/transparentDataEncryption` sub-resource.
  - Set the `properties.state` to `Enabled`.

For example:

```bicep
resource tde 'Microsoft.Sql/servers/databases/transparentDataEncryption@2023-08-01-preview' = {
  parent: database
  name: 'current'
  properties: {
    state: 'Enabled'
  }
}
```

### Configure with Azure CLI

```bash
az sql db tde set --status Enabled -s '<server_name>' -d '<database>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
Set-AzSqlDatabaseTransparentDataEncryption -ResourceGroupName '<resource_group>' -ServerName '<server_name>' -DatabaseName '<database>' -State Enabled
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Transparent Data Encryption on SQL databases should be enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/SQL/SqlDBEncryption_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/17k78e20-9358-41c9-923c-fb736d382a12`
- [Deploy SQL DB transparent data encryption](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/SQL/SqlDBEncryption_DINE.json)
  `/providers/Microsoft.Authorization/policyDefinitions/86a912f6-9a06-4e26-b447-11b16ba8659f`

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-at-rest)
- [Transparent data encryption for SQL Database](https://learn.microsoft.com/azure/azure-sql/database/transparent-data-encryption-tde-overview?view=azuresql)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/databases/transparentdataencryption)
