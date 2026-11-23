---
reviewed: 2026-11-23
severity: Awareness
pillar: Security
category: SE:07 Encryption
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.CMK/
---

# Use customer-managed keys for Azure DocumentDB when required

## SYNOPSIS

Azure DocumentDB clusters should use customer-managed encryption keys when required.

## DESCRIPTION

Azure DocumentDB encrypts data, logs, and backups at rest with service-managed keys by default.
Customer-managed keys provide control over the encryption key lifecycle when organizational or regulatory requirements demand it.
They also introduce responsibilities for key availability, rotation, permissions, and recovery.
Enable this check only when your organization requires customer-managed keys.

## RECOMMENDATION

Consider configuring a Key Vault key and an attached user-assigned managed identity when customer-managed encryption is required.

## EXAMPLES

### Configure with Azure template

Configure customer-managed encryption at cluster creation.
The identity must be assigned to the cluster and have the necessary permissions on the Key Vault key.
Declare `administratorPassword` as a `secureString` parameter.

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2026-06-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "UserAssigned",
    "userAssignedIdentities": {
      "[parameters('identityId')]": {}
    }
  },
  "properties": {
    "administrator": {
      "userName": "clusterAdmin",
      "password": "[parameters('administratorPassword')]"
    },
    "authConfig": { "allowedModes": ["NativeAuth", "MicrosoftEntraID"] },
    "compute": { "tier": "M30" },
    "storage": { "sizeGb": 128 },
    "sharding": { "shardCount": 1 },
    "encryption": {
      "customerManagedKeyEncryption": {
        "keyEncryptionKeyUrl": "[parameters('keyUrl')]",
        "keyEncryptionKeyIdentity": {
          "identityType": "UserAssignedIdentity",
          "userAssignedIdentityResourceId": "[parameters('identityId')]"
        }
      }
    }
  }
}
```

### Configure with Bicep

```bicep
param name string
param location string = resourceGroup().location
param identityId string
param keyUrl string
@secure()
param administratorPassword string

resource cluster 'Microsoft.DocumentDB/mongoClusters@2026-06-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    administrator: {
      userName: 'clusterAdmin'
      password: administratorPassword
    }
    authConfig: { allowedModes: ['NativeAuth', 'MicrosoftEntraID'] }
    compute: { tier: 'M30' }
    storage: { sizeGb: 128 }
    sharding: { shardCount: 1 }
    encryption: {
      customerManagedKeyEncryption: {
        keyEncryptionKeyUrl: keyUrl
        keyEncryptionKeyIdentity: {
          identityType: 'UserAssignedIdentity'
          userAssignedIdentityResourceId: identityId
        }
      }
    }
  }
}
```

## NOTES

### Rule configuration

<!-- module:config rule AZURE_DOCUMENTDB_REQUIRE_CMK -->

Set `AZURE_DOCUMENTDB_REQUIRE_CMK` to `true` to enable this rule.
The default is `false`.

```yaml
configuration:
  AZURE_DOCUMENTDB_REQUIRE_CMK: true
```

The rule checks the key URL, the encryption identity configuration, and attachment of that identity to the cluster.
It does not validate Key Vault permissions, network reachability, key state, or successful encryption operations.
Configure Key Vault soft delete and purge protection and grant the identity the required encryption permissions.

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Data encryption in Azure DocumentDB](https://learn.microsoft.com/azure/documentdb/database-encryption-at-rest)
- [Configure customer-managed encryption](https://learn.microsoft.com/azure/documentdb/how-to-data-encryption)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
