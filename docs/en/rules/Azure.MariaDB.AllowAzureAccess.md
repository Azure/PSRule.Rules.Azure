---
severity: Important
pillar: Security
category: Network security and containment
resource: Azure Database for MariaDB
resourceType: Microsoft.DBforMariaDB/servers,Microsoft.DBforMariaDB/servers/firewallRules
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.AllowAzureAccess/
---

# Disable MariaDB Allow access to Azure services firewall rule

## SYNOPSIS

Determine if access from Azure services is required.

## DESCRIPTION

Allow access to Azure services, permits any Azure service including other Azure customers, network based-access to databases on the same Azure Database for MariaDB server instance.
If network based access is permitted, authentication is still required.

Enabling access from Azure services is useful in certain cases where fixed outgoing IP addresses isn't available for the services.

## RECOMMENDATION

Where fixed outgoing IP addresses are available for the Azure services, configure IP or virtual network based firewall rules instead of using Allow access to Azure services.

Determine if access from Azure services is required for the services connecting to the hosted databases.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MariaDB Servers that pass this rule:

- Deploy a `Microsoft.DBforMariaDB servers/firewallRules` sub-resource (child resource).
- Set the `properties.startIpAddress` and `properties.endIpAddress` property to a valid IPv4 address format.

For example:

```json
{
  "type": "Microsoft.DBforMariaDB/servers",
  "apiVersion": "2018-06-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "[parameters('skuTier')]",
    "capacity": "[parameters('skuCapacity')]",
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
      "backupRetentionDays": "[parameters('backupRetentionDays')]",
      "geoRedundantBackup": "[parameters('geoRedundantBackup')]"
    }
  },
  "resources": [
    {
      "type": "Microsoft.DBforMariaDB/servers/firewallRules",
      "apiVersion": "2018-06-01",
      "name": "MariaDbServer001/FunctionApp",
      "properties": {
        "startIpAddress": "20.67.176.40",
        "endIpAddress": "20.67.176.40"
      },
      "dependsOn": [
        "[resourceId('Microsoft.DBforMariaDB/servers', parameters('serverName'))]"
      ]
    }
  ]
}
```

### Configure with Bicep

- Deploy a `Microsoft.DBforMariaDB servers/firewallRules` sub-resource (child resource).
- Set the `properties.startIpAddress` and `properties.endIpAddress` property to a valid IPv4 address format.

For example:

```bicep
resource mariaDbServer 'Microsoft.DBforMariaDB/servers@2018-06-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: skuTier
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
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
  }
}

resource mariaDbServerFirewallRule 'Microsoft.DBforMariaDB/servers/firewallRules@2018-06-01' = {
  name: 'MariaDbServer001/FunctionApp'
  parent: mariaDbServer
  properties: {
    startIpAddress: '20.67.176.40'
    endIpAddress: '20.67.176.40'
  }
}
```

## LINKS

- [Network security and containment](https://learn.microsoft.com/azure/architecture/framework/security/design-network)
- [Azure Database for MariaDB firewall rules](https://learn.microsoft.com/azure/mariadb/concepts-firewall-rules#connecting-from-azure)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers/firewallrules)
