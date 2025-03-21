---
reviewed: 2022/01/18
severity: Important
pillar: Security
category: Encryption
resource: Data Explorer
resourceType: Microsoft.Kusto/clusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ADX.DiskEncryption/
---

# Use disk encryption for Azure Data Explorer clusters

## SYNOPSIS

Use disk encryption for Azure Data Explorer (ADX) clusters.

## DESCRIPTION

Azure storage is encrypted at rest, however computing resources can additionally use disk encryption.
Disk encryption provides additional security for data at rest.

## RECOMMENDATION

Consider enabling disk encryption on Azure Data Explorer clusters.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set `properties.enableDiskEncryption` to `true`.

For example:

```json
{
    "type": "Microsoft.Kusto/clusters",
    "apiVersion": "2021-08-27",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Standard_D11_v2",
        "tier": "Standard"
    },
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "enableDiskEncryption": true
    }
}
```

### Configure with Bicep

To deploy clusters that pass this rule:

- Set `properties.enableDiskEncryption` to `true`.

For example:

```bicep
resource adx 'Microsoft.Kusto/clusters@2021-08-27' = {
  name: name
  location: location
  sku: {
    name: 'Standard_D11_v2'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableDiskEncryption: true
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption)
- [Secure your cluster using Disk Encryption in Azure Data Explorer](https://learn.microsoft.com/azure/data-explorer/cluster-disk-encryption)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters)
