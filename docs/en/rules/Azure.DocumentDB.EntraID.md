---
reviewed: 2026-11-23
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.EntraID/
---

# Azure DocumentDB clusters should use Microsoft Entra ID authentication

## SYNOPSIS

Azure DocumentDB clusters should have Microsoft Entra ID authentication enabled.

## DESCRIPTION

Azure DocumentDB clusters support multiple authentication modes including native authentication (connection string) and
Microsoft Entra ID authentication.
Native authentication uses MongoDB credentials (username/password) that are embedded in connection strings and
managed locally within the cluster.

Using Microsoft Entra ID authentication provides several security benefits:

- **Centralized identity management** - Single authoritative source for all user identities.
- **MongoDB role-based permissions** - Fine-grained access control using MongoDB's native role system with Entra ID identities.
- **Enhanced security features** - Multi-factor authentication, conditional access, and identity protection.
- **Reduced complexity** - Eliminates the need to manage separate database credentials.
- **Audit and compliance** - Centralized logging and monitoring of authentication events.

Microsoft Entra ID authentication should be enabled to ensure secure and centralized identity management for
Azure DocumentDB clusters.

## RECOMMENDATION

Consider enabling Microsoft Entra ID authentication on Azure DocumentDB clusters.

## EXAMPLES

### Configure with Azure template

To deploy Azure DocumentDB clusters that pass this rule:

- Set the `properties.authConfig.allowedModes` array to include `MicrosoftEntraID`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2025-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "administrator": {
      "userName": "[parameters('administratorUserName')]",
      "password": "[parameters('administratorPassword')]"
    },
    "serverVersion": "8.0",
    "authConfig": {
      "allowedModes": [
        "NativeAuth",
        "MicrosoftEntraID"
      ]
    },
    "compute": {
      "tier": "M30"
    },
    "storage": {
      "sizeGb": 128,
      "type": "PremiumSSD"
    },
    "sharding": {
      "shardCount": 1
    }
  }
}
```

### Configure with Bicep

To deploy Azure DocumentDB clusters that pass this rule:

- Set the `properties.authConfig.allowedModes` array to include `MicrosoftEntraID`.

For example:

```bicep
@secure()
param administratorPassword string
param administratorUserName string
param name string
param location string = resourceGroup().location

resource cluster 'Microsoft.DocumentDB/mongoClusters@2025-09-01' = {
  name: name
  location: location
  properties: {
    administrator: {
      userName: administratorUserName
      password: administratorPassword
    }
    serverVersion: '8.0'
    authConfig: {
      allowedModes: [
        'NativeAuth'
        'MicrosoftEntraID'
      ]
    }
    compute: {
      tier: 'M30'
    }
    storage: {
      sizeGb: 128
      type: 'PremiumSSD'
    }
    sharding: {
      shardCount: 1
    }
  }
}
```

## NOTES

**Important:** For initial deployment, you must include both `NativeAuth` and `MicrosoftEntraID` in the `allowedModes` array.
Deploying with only `MicrosoftEntraID` will cause the deployment to fail as the initial setup process requires native authentication.
Declare `administratorPassword` as a `secureString` parameter in the Azure template.
After deployment is complete and Entra ID users are configured and can connect, you can optionally remove `NativeAuth` for enhanced security.

This rule applies to Azure DocumentDB, formerly Azure Cosmos DB for MongoDB vCore.
The resource type remains `Microsoft.DocumentDB/mongoClusters`.
The previous rule name, `Azure.Cosmos.MongoEntraID`, remains a compatibility alias.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Security: Level 1](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level1)
- [What is Azure DocumentDB?](https://learn.microsoft.com/azure/documentdb/overview)
- [Connect to Azure DocumentDB using role-based access control and Microsoft Entra ID](https://learn.microsoft.com/azure/documentdb/how-to-connect-role-based-access-control)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
