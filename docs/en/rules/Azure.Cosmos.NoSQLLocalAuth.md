---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.NoSQLLocalAuth/
---

# Cosmos DB NoSQL API account access keys are enabled

## SYNOPSIS

Access keys allow depersonalized access to Cosmos DB NoSQL API accounts using a shared secret.

## DESCRIPTION

Every request to a Cosmos DB Account resource must be authenticated.
Cosmos DB supports authenticating requests using either Entra ID (previously Azure AD) identities or local authentication.
Local authentication uses account keys that are granted permissions to the entire Cosmos DB Account.

Using Entra ID provides consistency as a single authoritative source which:

- Increases clarity and reduces security risks from human errors and configuration complexity.
- Allows granting of permissions using role-based access control (RBAC).
- Provides support for advanced identity security and governance features.

Disabling local authentication ensures that Entra ID is used exclusively for authentication.
Any subsequent requests to the resource using account keys will be rejected.

This rule applies only to Cosmos DB accounts using the NoSQL API.
Enforcing role-based access control as the only authentication method is currently only supported for the NoSQL API.

## RECOMMENDATION

Consider disabling local authentication on Cosmos DB NoSQL API accounts and using Entra ID.

## EXAMPLES

### Configure with Bicep

To deploy database accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' = {
  name: name
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    disableLocalAuth: true
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
  }
}
```

<!-- external:avm avm/res/document-db/database-account disableLocalAuthentication -->

### Configure with Azure template

To deploy database accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2025-04-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "kind": "GlobalDocumentDB",
  "properties": {
    "disableLocalAuth": true,
    "locations": [
      {
        "locationName": "[parameters('location')]",
        "failoverPriority": 0,
        "isZoneRedundant": true
      }
    ]
  }
}
```

## NOTES

This rule has been renamed from `Azure.Cosmos.DisableLocalAuth`.
The alias `Azure.Cosmos.DisableLocalAuth` is deprecated and will be removed in a future release.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Connect to Azure Cosmos DB for NoSQL using role-based access control and Microsoft Entra ID](https://learn.microsoft.com/azure/cosmos-db/nosql/how-to-connect-role-based-access-control)
- [Azure security baseline for Azure Cosmos DB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
