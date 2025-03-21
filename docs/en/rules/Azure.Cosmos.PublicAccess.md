---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.PublicAccess/
---

# Disable public network access on Cosmos DB

## SYNOPSIS

Azure Cosmos DB should have public network access disabled.

## DESCRIPTION

Disabling public network access improves security by ensuring that the resource isn't exposed on the public internet.
You can control exposure of your resources by creating private endpoints instead.

## RECOMMENDATION

Consider disabling public network access on Cosmos DB, using private endpoints to control connectivity for data plane operations.

## EXAMPLES

### Configure with Azure template

To deploy database accounts that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2023-11-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "kind": "GlobalDocumentDB",
  "properties": {
    "publicNetworkAccess": "Disabled",
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

- Set the `properties.publicNetworkAccess` property to `Disabled`.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: name
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Disabled'
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

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)  
- [Configure Azure Private Link for an Azure Cosmos DB account](https://learn.microsoft.com/azure/cosmos-db/how-to-configure-private-endpoints)
- [Azure security baseline for Azure Cosmos DB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#ns-2-secure-cloud-services-with-network-controls)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
