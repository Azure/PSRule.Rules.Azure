---
severity: Important
pillar: Security
category: Application endpoints
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.Firewall/
---

# Configure Azure Storage firewall

## SYNOPSIS

Storage Accounts should only accept explicitly allowed traffic.

## DESCRIPTION

By default, storage accounts accept connections from clients on any network.
To limit access to selected networks, you must first change the default action.

After changing the default action from `Allow` to `Deny`, configure one or more rules to allow traffic.
Traffic can be allowed from:

- Azure services on the trusted service list.
- IP address or CIDR range.
- Private endpoint connections.
- Azure virtual network subnets with a Service Endpoint.

## RECOMMENDATION

Consider configuring storage firewall to restrict network access to permitted clients only.
Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.networkAcls.defaultAction` property to `Deny`.

For example:

```json
{
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2021-04-01",
    "name": "st0000001",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Standard_GRS"
    },
    "kind": "StorageV2",
    "properties": {
        "supportsHttpsTrafficOnly": true,
        "accessTier": "Hot",
        "allowBlobPublicAccess": false,
        "minimumTlsVersion": "TLS1_2",
        "networkAcls": {
            "defaultAction": "Deny"
        }
    }
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `properties.networkAcls.defaultAction` property to `Deny`.

For example:

```bicep
resource st0000001 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'st0000001'
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}
```

## NOTES

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded.
Azure storage firewall is not supported for Cloud Shell storage accounts.

## LINKS

- [Public endpoints](https://docs.microsoft.com/azure/architecture/framework/security/design-network-endpoints#public-endpoints)
- [Configure Azure Storage firewalls and virtual networks](https://docs.microsoft.com/azure/storage/common/storage-network-security)
- [Use private endpoints for Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-private-endpoints)
- [Persist files in Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/persisting-shell-storage)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts#NetworkRuleSet)
