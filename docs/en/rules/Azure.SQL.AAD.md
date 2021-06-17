---
severity: Critical
pillar: Security
category: Identity and access management
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.SQL.AAD.md
---

# Use AAD authentication with SQL databases

## SYNOPSIS

Use Azure Active Directory (AAD) authentication with Azure SQL databases.

## DESCRIPTION

Azure SQL Database offer two authentication models, Azure Active Directory (AAD) and SQL logins.
AAD authentication provides additional features over SQL logins that improve authentication security.

When using AAD authentication, Azure Multi-Factor Authentication (MFA) and Conditional Access are available.

## RECOMMENDATION

Consider using Azure Active Directory (AAD) authentication with SQL databases.

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
            "type": "Microsoft.Sql/servers/administrators",
            "apiVersion": "2019-06-01-preview",
            "name": "[concat(parameters('serverName'), '/ActiveDirectory')]",
            "dependsOn": [
                "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
            ],
            "properties": {
                "administratorType": "ActiveDirectory",
                "login": "[parameters('aadAdminName')]",
                "sid": "[parameters('aadAdminId')]",
                "tenantId": "[subscription().tenantId]"
            }
        }
    ]
}
```

### Configure with Azure CLI

```bash
az sql server ad-admin create -s '<server_name>' -g '<resource_group>' -u '<user_name>' -i '<object_id>'
```

### Configure with Azure PowerShell

```powershell
Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName '<resource_group>' -ServerName '<server_name>' -DisplayName '<user_name>'
```

## LINKS

- [Configure and manage Azure Active Directory authentication with SQL](https://docs.microsoft.com/azure/sql-database/sql-database-aad-authentication-configure)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers/administrators)
- [Using Multi-factor AAD authentication with Azure SQL Database](https://docs.microsoft.com/azure/sql-database/sql-database-ssms-mfa-authentication)
- [Conditional Access (MFA) with Azure SQL Database](https://docs.microsoft.com/azure/sql-database/sql-database-conditional-access)
