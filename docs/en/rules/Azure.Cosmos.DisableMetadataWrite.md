---
reviewed: 2024-05-01
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Cosmos DB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.DisableMetadataWrite/
---

# Restrict user access to data operations in Azure Cosmos DB

## SYNOPSIS

Use Entra ID identities for management place operations in Azure Cosmos DB.

## DESCRIPTION

Cosmos DB provides two authorization options for interacting with the database:

- Entra ID identities (previously known as Azure AD).
  Can be used to authorize account and resource management operations.
- Keys and resource tokens.
  Can be used to authorize resource management and data operations.

Resource management operations include management of databases, indexes, and containers.
By default, keys are permitted to perform resource management operations.
You can restrict these operations to Azure Resource Manager (ARM) calls only.

## RECOMMENDATION

Consider limiting key and resource tokens to data plane operations only.
Use Microsoft Entra ID identities for authorizing account and resource management operations.

## EXAMPLES

### Configure with Azure template

To deploy Cosmos DB accounts that pass this rule:

- Set the `Properties.disableKeyBasedMetadataWriteAccess` property to `true`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2023-04-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "enableFreeTier": false,
    "consistencyPolicy": {
      "defaultConsistencyLevel": "Session"
    },
    "databaseAccountOfferType": "Standard",
    "locations": [
      {
        "locationName": "[parameters('location')]",
        "failoverPriority": 0,
        "isZoneRedundant": true
      }
    ],
    "disableKeyBasedMetadataWriteAccess": true
  }
}
```

### Configure with Bicep

To deploy Cosmos DB accounts that pass this rule:

- Set the `Properties.disableKeyBasedMetadataWriteAccess` property to `true`.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: name
  location: location
  properties: {
    enableFreeTier: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
    disableKeyBasedMetadataWriteAccess: true
  }
}
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Cosmos DB key based metadata write access should be disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cosmos%20DB/Cosmos_DisableMetadata_Append.json)
  `/providers/Microsoft.Authorization/policyDefinitions/4750c32b-89c0-46af-bfcb-2e4541a818d5`

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Restrict user access to data operations in Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/how-to-restrict-user-data)
- [Secure access to data in Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/secure-access-to-data)
- [How does Azure Cosmos DB secure my database?](https://learn.microsoft.com/azure/cosmos-db/database-security#how-does-azure-cosmos-db-secure-my-database)
- [Access control in the Azure Cosmos DB SQL API](https://learn.microsoft.com/rest/api/cosmos-db/access-control-on-cosmosdb-resources)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
