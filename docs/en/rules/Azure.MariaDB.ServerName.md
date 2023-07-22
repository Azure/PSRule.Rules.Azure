---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.ServerName/
---

# Use valid server names

## SYNOPSIS

Azure Database for MariaDB servers should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Azure Database for MariaDB server names are:

- Between 3 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- MariaDB server names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure Database for MariaDB server naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

To deploy servers that pass this rule:

- Set the `name` property to align to resource naming requirements.

For example:

```json
{
  "type": "Microsoft.DBforMariaDB/servers",
  "apiVersion": "2018-06-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('sku')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('skuCapacity')]",
    "size": "[format('{0}', parameters('skuSizeMB'))]",
    "family": "Gen5"
  },
  "properties": {
    "sslEnforcement": "Enabled",
    "minimalTlsVersion": "TLS1_2",
    "createMode": "Default",
    "version": "10.3",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "publicNetworkAccess": "Disabled",
    "storageProfile": {
      "storageMB": "[parameters('skuSizeMB')]",
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  }
}
```

### Configure with Bicep

To deploy servers that pass this rule:

- Set the `name` property to align to resource naming requirements.

For example:

```bicep
resource server 'Microsoft.DBforMariaDB/servers@2018-06-01' = {
  name: name
  location: location
  sku: {
    name: sku
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${skuSizeMB}'
    family: 'Gen5'
  }
  properties: {
    sslEnforcement: 'Enabled'
    minimalTlsVersion: 'TLS1_2'
    createMode: 'Default'
    version: '10.3'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
    storageProfile: {
      storageMB: skuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}
```

## NOTES

This rule does not check if Azure Database for MariaDB server names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions Azure Database for MariaDB resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Resource naming and tagging decision guide](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming-and-tagging-decision-guide)
- [Abbreviation examples for Azure resources](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers)
