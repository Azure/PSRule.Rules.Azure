---
reviewed: 2026-11-23
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.PublicAccess/
---

# Disable public access to Azure DocumentDB clusters

## SYNOPSIS

Azure DocumentDB clusters should disable public network access.

## DESCRIPTION

Disabling the public endpoint reduces exposure to connections from the internet.
Use private endpoints and private DNS to connect applications to Azure DocumentDB through a virtual network.
Configure and test private connectivity before disabling an existing public endpoint.

## RECOMMENDATION

Consider setting `properties.publicNetworkAccess` to `Disabled` and using private endpoints.

## EXAMPLES

### Configure with Azure template

Set `properties.publicNetworkAccess` to `Disabled` on the cluster resource.
Declare `administratorPassword` as a `secureString` parameter.

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2026-06-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "administrator": {
      "userName": "clusterAdmin",
      "password": "[parameters('administratorPassword')]"
    },
    "authConfig": {
      "allowedModes": ["NativeAuth", "MicrosoftEntraID"]
    },
    "compute": { "tier": "M30" },
    "storage": { "sizeGb": 128 },
    "sharding": { "shardCount": 1 },
    "publicNetworkAccess": "Disabled"
  }
}
```

### Configure with Bicep

```bicep
param name string
param location string = resourceGroup().location
@secure()
param administratorPassword string

resource cluster 'Microsoft.DocumentDB/mongoClusters@2026-06-01' = {
  name: name
  location: location
  properties: {
    administrator: {
      userName: 'clusterAdmin'
      password: administratorPassword
    }
    authConfig: {
      allowedModes: ['NativeAuth', 'MicrosoftEntraID']
    }
    compute: { tier: 'M30' }
    storage: { sizeGb: 128 }
    sharding: { shardCount: 1 }
    publicNetworkAccess: 'Disabled'
  }
}
```

## NOTES

This rule requires the explicit `Disabled` setting; an omitted or empty setting fails.
It does not check whether private endpoints or DNS are correctly configured.
Without working private connectivity, disabling public access prevents application connections.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Secure your Azure DocumentDB cluster](https://learn.microsoft.com/azure/documentdb/security)
- [Configure private access](https://learn.microsoft.com/azure/documentdb/how-to-private-link)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
