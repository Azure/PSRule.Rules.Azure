---
severity: Important
pillar: Security
category: Security operations
resource: Azure Database for PostgreSQL
resourceType: Microsoft.DBforPostgreSQL/servers,Microsoft.DBforPostgreSQL/servers/securityAlertPolicies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.DefenderCloud/
---

# Use Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Cloud for Azure Database for PostgreSQL.

## DESCRIPTION

Defender for Cloud detects anomalous activities indicating unusual and potentially harmful attempts to access or exploit databases.

## RECOMMENDATION

Enable Microsoft Defender for Cloud for Azure Database for PostgreSQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for PostgreSQL Single Servers that pass this rule:

- Deploy a `Microsoft.DBforPostgreSQL/servers/securityAlertPolicies` sub-resource (child resource).
- Set the `properties.state` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.DBforPostgreSQL/servers",
  "apiVersion": "2017-12-01",
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
    "version": "[parameters('postgresqlVersion')]",
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
      "type": "Microsoft.DBforPostgreSQL/servers/securityAlertPolicies",
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

To deploy Azure Database for PostgreSQL Single Servers that pass this rule:

- Deploy a `Microsoft.DBforPostgreSQL/servers/securityAlertPolicies` sub-resource (child resource).
- Set the `properties.state` property to `Enabled`.

For example:

```bicep
resource postgresqlDbServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
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
    version: postgresqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: SkuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}

resource postgresqlDefender 'Microsoft.DBforPostgreSQL/servers/securityAlertPolicies@2017-12-01' = {
  name: 'Default'
  parent: postgresqlDbServer
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

This rule is only applicable for the Azure Database for PostgreSQL Single Server deployment model.

Azure Database for PostgreSQL Flexible Server deployment model does not currently support Microsoft Defender for Cloud.

## LINKS

- [Security operations](https://learn.microsoft.com/azure/architecture/framework/security/security-operations)
- [Enable Microsoft Defender for open-source relational databases](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-usage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/servers/securityalertpolicies)
