---
severity: Important
pillar: Security
category: Security operations
resource: Azure Database for MySQL
resourceType: Microsoft.DBforMySQL/servers,Microsoft.DBforMySQL/servers/securityAlertPolicies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.DefenderCloud/
---

# Use Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Cloud for Azure Database for MySQL.

## DESCRIPTION

Defender for Cloud detects anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases.

## RECOMMENDATION

Enable Microsoft Defender for Cloud for Azure Database for MySQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MySQL Single Servers that pass this rule:

- Deploy a `Microsoft.DBforMySQL/servers/securityAlertPolicies` sub-resource (child resource).
- Set the `properties.state` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/servers",
  "apiVersion": "2017-12-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('skuCapacity')]",
    "size": "[format('{0}', parameters('SkuSizeMB'))]",
    "family": "[parameters('skuFamily')]"
  },
  "properties": {
    "createMode": "Default",
    "version": "[parameters('mysqlVersion')]",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "storageProfile": {
      "storageMB": "[parameters('SkuSizeMB')]",
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  },
  "resources": [
    {
      "type": "Microsoft.DBforMySQL/servers/securityAlertPolicies",
      "apiVersion": "2017-12-01",
      "name": "Default",
      "dependsOn": ["[parameters('serverName')]"],
      "properties": {
        "emailAccountAdmins": true,
        "emailAddresses": ["soc@contoso.com"],
        "retentionDays": 14,
        "state": "Enabled",
        "storageAccountAccessKey": "account-key",
        "storageEndpoint": "https://contoso.blob.core.windows.net"
      }
    }
  ]
}
```

### Configure with Bicep

To deploy Azure Database for MySQL Single Servers that pass this rule:

- Deploy a `Microsoft.DBforMySQL/servers/securityAlertPolicies` sub-resource (child resource).
- Set the `properties.state` property to `Enabled`.

For example:

```bicep
resource mysqlDbServer 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${SkuSizeMB}'
    family: skuFamily
  }
  properties: {
    createMode: 'Default'
    version: mysqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: SkuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}

resource mysqlDefender 'Microsoft.DBforMySQL/servers/securityAlertPolicies@2017-12-01' = {
  name: 'Default'
  parent: mysqlDbServer
  properties: {
    emailAccountAdmins: true
    emailAddresses: ['soc@contoso.com']
    retentionDays: 14
    state: 'Enabled'
    storageAccountAccessKey: 'account-key'
    storageEndpoint: 'https://contoso.blob.core.windows.net'
  }
}
```

## NOTES

This rule is only applicable for the Azure Database for MySQL Single Server deployment model.

Azure Database for MySQL Flexible Server deployment model does not currently support Microsoft Defender for Cloud.

## LINKS

- [Security operations](https://learn.microsoft.com/azure/architecture/framework/security/security-operations)
- [Enable Microsoft Defender for open-source relational databases](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-usage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers/securityalertpolicies)
