---
severity: Important
pillar: Security
category: Security operations
resource: Azure Database for MariaDB
resourceType: Microsoft.DBforMariaDB/servers,Microsoft.DBforMariaDB/servers/securityAlertPolicies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.DefenderCloud/
---

# Use Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Cloud for Azure Database for MariaDB.

## DESCRIPTION

Defender for Cloud detects anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases.

## RECOMMENDATION

Enable Microsoft Defender for Cloud for Azure Database for MariaDB.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MariaDB Servers that pass this rule:

- Deploy a `Microsoft.DBforMariaDB/servers/securityAlertPolicies` sub-resource (child resource).
- Set the `properties.state` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.DBforMariaDB/servers",
  "apiVersion": "2018-06-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('SkuCapacity')]",
    "size": "[format('{0}', parameters('skuSizeMB'))]",
    "family": "[parameters('skuFamily')]"
  },
  "properties": {
    "createMode": "Default",
    "version": "[parameters('mariadbVersion')]",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "storageProfile": {
      "storageMB": "[parameters('skuSizeMB')]",
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  },
  "resources": [
    {
      "type": "Microsoft.DBforMariaDB/servers/securityAlertPolicies",
      "apiVersion": "2018-06-01",
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

To deploy Azure Database for MariaDB Servers that pass this rule:

- Deploy a `Microsoft.DBforMariaDB/servers/securityAlertPolicies` sub-resource (child resource).
- Set the `properties.state` property to `Enabled`.

For example:

```bicep
resource mariaDbServer 'Microsoft.DBforMariaDB/servers@2018-06-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${skuSizeMB}' 
    family: skuFamily
  }
  properties: {
    createMode: 'Default'
    version: mariadbVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: skuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}

resource mariaDbDefender 'Microsoft.DBforMariaDB/servers/securityAlertPolicies@2018-06-01' = {
  name: 'Default'
  parent: MariaDbServer
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

## LINKS

- [Security operations](https://learn.microsoft.com/azure/architecture/framework/security/security-operations)
- [Enable Microsoft Defender for open-source relational databases](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-usage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers/securityalertpolicies)
