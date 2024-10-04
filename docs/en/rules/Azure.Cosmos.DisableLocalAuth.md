---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Cosmos DB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.DisableLocalAuth/
---

# Disable local authentication on Cosmos DB

## SYNOPSIS

Azure Cosmos DB should have local authentication disabled.

## DESCRIPTION

Every request to an Cosmos DB Account resource must be authenticated.
Cosmos DB supports authenticating requests using either Entra ID (previously Azure AD) identities or local authentication.
Local authentication uses accounts keys that are granted permissions to the entire Cosmos DB Account.

Using Entra ID, provides consistency as a single authoritative source which:

- Increases clarity and reduces security risks from human errors and configuration complexity.
- Allows granting of permissions using role-based access control (RBAC).
- Provides support for advanced identity security and governance features.

Disabling local authentication ensures that Entra ID is used exclusively for authentication.
Any subsequent requests to the resource using account keys will be rejected.

## RECOMMENDATION

Consider disabling local authentication on Cosmos DB.

## EXAMPLES

### Configure with Azure template

To deploy database accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2023-11-15",
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

### Configure with Bicep

To deploy database accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
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

## NOTES

Enforcing role-based access control as the only authentication method is currently only supported for the `NoSQL API`.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Enforcing role-based access control as the only authentication method](https://learn.microsoft.com/azure/cosmos-db/how-to-setup-rbac#disable-local-auth)
- [Configure role-based access control with Microsoft Entra ID for your Azure Cosmos DB account management plane](https://learn.microsoft.com/azure/cosmos-db/role-based-access-control)
- [Configure role-based access control with Microsoft Entra ID for your Azure Cosmos DB account data plane](https://learn.microsoft.com/azure/cosmos-db/how-to-setup-rbac)
- [Azure security baseline for Azure Cosmos DB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
