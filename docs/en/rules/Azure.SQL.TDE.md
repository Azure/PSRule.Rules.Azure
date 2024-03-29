---
severity: Critical
pillar: Security
category: Data protection
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

## RECOMMENDATION

Consider enable Transparent Data Encryption (TDE) for Azure SQL Databases to perform encryption at rest.

## EXAMPLES

### Configure with Azure template

```json
{
    "type": "Microsoft.Sql/servers/databases",
    "apiVersion": "2020-08-01-preview",
    "name": "[variables('dbName')]",
    "location": "[parameters('location')]",
    "sku": {
        "name": "[parameters('sku')]"
    },
    "kind": "v12.0,user",
    "properties": {
        "collation": "SQL_Latin1_General_CP1_CI_AS",
        "maxSizeBytes": "[mul(parameters('maxSizeMB'), 1048576)]",
        "catalogCollation": "SQL_Latin1_General_CP1_CI_AS",
        "zoneRedundant": false,
        "readScale": "Disabled",
        "storageAccountType": "GRS"
    },
    "resources": [
        {
            "type": "Microsoft.Sql/servers/databases/transparentDataEncryption",
            "apiVersion": "2014-04-01",
            "name": "[concat(variables('dbName'), '/current')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[resourceId('Microsoft.Sql/servers/databases', parameters('serverName'), parameters('databaseName'))]"
            ],
            "properties": {
                "status": "Enabled"
            }
        }
    ]
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

## LINKS

- [Transparent data encryption for SQL Database](https://learn.microsoft.com/azure/sql-database/transparent-data-encryption-azure-sql)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/databases/transparentdataencryption)
