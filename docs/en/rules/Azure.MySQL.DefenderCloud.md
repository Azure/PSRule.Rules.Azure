---
reviewed: 2024-06-01
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.DefenderCloud/
---

# Use Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Cloud for Azure Database for MySQL.

## DESCRIPTION

Microsoft Defender for Cloud detects anomalous activities that may indicate unusual and potentially harmful attempts to access or exploit your databases. 
It provides advanced threat protection for your Azure Database for MySQL, helping to safeguard your data and maintain compliance.

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

For the Azure Database for MySQL Flexible Server deployment model, enabling Microsoft Defender for Cloud is handled differently as the `Microsoft.DBforMySQL/flexibleServers/advancedThreatProtectionSettings` resource is read-only. 
It can be enabled through either of the following methods:

- Subscription Level Enablement: Enable the `open-source relational databases` resource type under the Microsoft Defender for Cloud Databases plan for the subscription where the server is located.
- Resource Level Enablement: Manually enable Microsoft Defender for Cloud for the specific resource via the Azure portal under the resource blade.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/en-us/azure/well-architected/security/monitor-threats)
- [Azure security baseline for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Enable Microsoft Defender for open-source relational databases](https://learn.microsoft.com/azure/defender-for-cloud/enable-defender-for-databases-azure)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers/advancedthreatprotectionsettings)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers/securityalertpolicies)
