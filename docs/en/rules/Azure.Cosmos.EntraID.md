---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.EntraID/
---

# MongoDB vCore clusters should use Microsoft Entra ID authentication

## SYNOPSIS

MongoDB vCore clusters should have Microsoft Entra ID authentication enabled.

## DESCRIPTION

MongoDB vCore clusters support multiple authentication modes including native authentication (connection string) and
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
MongoDB vCore clusters.

## RECOMMENDATION

Consider enabling Microsoft Entra ID authentication on MongoDB vCore clusters.

## EXAMPLES

### Configure with Azure template

To deploy MongoDB vCore clusters that pass this rule:

- Set the `properties.authConfig.allowedModes` array to include `MicrosoftEntraID`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2025-04-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
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
    }
  }
}
```

### Configure with Bicep

To deploy MongoDB vCore clusters that pass this rule:

- Set the `properties.authConfig.allowedModes` array to include `MicrosoftEntraID`.

For example:

```bicep
resource mongoCluster 'Microsoft.DocumentDB/mongoClusters@2025-04-01-preview' = {
  name: name
  location: location
  properties: {
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
  }
}
```

## NOTES

**Important:** For initial deployment, you must include both `NativeAuth` and `MicrosoftEntraID` in the `allowedModes` array.
Deploying with only `MicrosoftEntraID` will cause the deployment to fail as the initial setup process requires native authentication.
After deployment is complete and Entra ID users are configured, you can optionally remove `NativeAuth` for enhanced security.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Microsoft Entra ID authentication with Azure Cosmos DB for MongoDB vCore](https://learn.microsoft.com/azure/cosmos-db/mongodb/vcore/entra-authentication)
- [Configure Microsoft Entra ID authentication for an Azure Cosmos DB for MongoDB vCore cluster](https://learn.microsoft.com/azure/cosmos-db/mongodb/vcore/how-to-configure-entra-authentication?tabs=portal%2Cazure-portal)
- [Azure security baseline for Azure Cosmos DB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#im-3-manage-application-identities-securely-and-automatically)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
