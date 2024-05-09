---
severity: Critical
pillar: Security
category: Authentication
resource: Cosmos DB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.DisableLocalAuth/
---

# Disable local authentication on Cosmos DB

## SYNOPSIS

Azure Cosmos DB should have local authentication disabled.

## DESCRIPTION

Cosmos DB can have local authentication methods enabled or disabled.

Disabling local authentication ensures that Entra ID (previously Azure Active Directory) is used exclusively for authentication.
Using Entra ID, provides consistency as a single authoritative source which:

- Increases clarity and reduces security risks from human errors and configuration complexity.
- Provides support for advanced identity security and governance features.

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
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
