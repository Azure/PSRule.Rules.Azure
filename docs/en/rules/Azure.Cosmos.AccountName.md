---
reviewed: 2025-11-01
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.AccountName/
---

# Use valid Cosmos DB account names

## SYNOPSIS

Cosmos DB account names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Cosmos DB account names are:

- Between 3 and 44 characters long.
- Lowercase letters, numbers, and hyphens.
- Start and end with letters and numbers.
- Cosmos DB account names must be globally unique.

## RECOMMENDATION

Consider using names that meet Cosmos DB account naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy accounts that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(3)
@maxLength(44)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource account 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' = {
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

<!-- external:avm avm/res/document-db/database-account name -->

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 3,
      "maxLength": 44,
      "metadata": {
        "description": "The name of the resource."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.DocumentDB/databaseAccounts",
      "apiVersion": "2025-04-15",
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
  ]
}
```

## NOTES

This rule does not check if Cosmos DB account names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
