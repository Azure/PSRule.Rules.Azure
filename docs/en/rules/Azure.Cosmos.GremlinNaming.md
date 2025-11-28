---
reviewed: 2025-11-24
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Cosmos DB for Apache Gremlin account
resourceType: Microsoft.DocumentDb/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.GremlinNaming/
---

# Cosmos DB for Apache Gremlin account resources must use standard naming

## SYNOPSIS

Cosmos DB for Apache Gremlin account resources without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For Cosmos DB for Apache Gremlin account, the Cloud Adoption Framework (CAF) recommends using the `cosgrm-` prefix.

Requirements for Cosmos DB for Apache Gremlin account resource names:

- Between 3 and 44 characters long.
- Can include alphanumeric characters, hyphens, underscores, and periods (restrictions vary by resource type).
- Resource names must be unique within their scope.

## RECOMMENDATION

Consider creating Cosmos DB for Apache Gremlin account resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

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

resource gremlin 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' = {
  name: name
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    capabilities: [
      {
        name: 'EnableGremlin'
      }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
    databaseAccountOfferType: 'Standard'
    minimalTlsVersion: 'Tls12'
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
  }
  tags: {
    defaultExperience: 'Gremlin (graph)'
  }
}
```

<!-- external:avm avm/res/document-db/database-account name -->

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

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
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.DocumentDB/databaseAccounts",
      "apiVersion": "2025-04-15",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "kind": "GlobalDocumentDB",
      "properties": {
        "capabilities": [
          {
            "name": "EnableGremlin"
          }
        ],
        "locations": [
          {
            "locationName": "[parameters('location')]",
            "failoverPriority": 0,
            "isZoneRedundant": true
          }
        ],
        "databaseAccountOfferType": "Standard",
        "minimalTlsVersion": "Tls12",
        "backupPolicy": {
          "type": "Periodic",
          "periodicModeProperties": {
            "backupIntervalInMinutes": 240,
            "backupRetentionIntervalInHours": 8,
            "backupStorageRedundancy": "Geo"
          }
        }
      },
      "tags": {
        "defaultExperience": "Gremlin (graph)"
      }
    }
  ]
}
```

## NOTES

This rule does not check if Cosmos DB for Apache Gremlin account resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_COSMOS_GREMLIN_NAME_FORMAT -->

To configure this rule set the `AZURE_COSMOS_GREMLIN_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_COSMOS_GREMLIN_NAME_FORMAT: '^cosgrm-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
