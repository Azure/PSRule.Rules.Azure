---
reviewed: 2024-04-09
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.MinTLS/
---

# Cosmos DB account minimum TLS version

## SYNOPSIS

Cosmos DB accounts should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Cosmos DB accepts for client communication is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure Cosmos DB lets you disable outdated protocols and enforce TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Azure template

To deploy database accounts that pass this rule:

- Set the `properties.minimalTlsVersion` property to `Tls12`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2023-11-15",
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
    "disableKeyBasedMetadataWriteAccess": true,
    "minimalTlsVersion": "Tls12"
  }
}
```

### Configure with Bicep

To deploy database accounts that pass this rule:

- Set the `properties.minimalTlsVersion` property to `Tls12`.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
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
    minimalTlsVersion: 'Tls12'
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Self-serve minimum TLS version enforcement in Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/self-serve-minimum-tls-enforcement)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
