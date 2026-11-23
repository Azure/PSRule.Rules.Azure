---
reviewed: 2026-11-23
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.Naming/
---

# Azure DocumentDB clusters must use a standard naming convention

## SYNOPSIS

Azure DocumentDB clusters without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

Standard names help operators identify resources, their environment, and their purpose.
Configure a regular expression that represents your organization's naming convention.
This rule evaluates names with a case-sensitive regular expression and is inactive until a naming format is configured.

## RECOMMENDATION

Consider configuring and applying an organizational naming convention for Azure DocumentDB.

## EXAMPLES

The following examples use the sample naming convention `^docdb-`.
This is an example, not a prescribed Azure abbreviation.
Declare `administratorPassword` as a `secureString` parameter in the Azure template.

### Configure with Azure template

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2026-06-01",
  "name": "docdb-prod-001",
  "location": "[parameters('location')]",
  "properties": {
    "administrator": {
      "userName": "clusterAdmin",
      "password": "[parameters('administratorPassword')]"
    },
    "authConfig": { "allowedModes": ["NativeAuth", "MicrosoftEntraID"] },
    "compute": { "tier": "M30" },
    "storage": { "sizeGb": 128 },
    "sharding": { "shardCount": 1 }
  }
}
```

### Configure with Bicep

```bicep
param location string = resourceGroup().location
@secure()
param administratorPassword string

resource cluster 'Microsoft.DocumentDB/mongoClusters@2026-06-01' = {
  name: 'docdb-prod-001'
  location: location
  properties: {
    administrator: {
      userName: 'clusterAdmin'
      password: administratorPassword
    }
    authConfig: { allowedModes: ['NativeAuth', 'MicrosoftEntraID'] }
    compute: { tier: 'M30' }
    storage: { sizeGb: 128 }
    sharding: { shardCount: 1 }
  }
}
```

## NOTES

### Rule configuration

<!-- module:config rule AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT -->

Set `AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT` to the required regular expression.
The default value is an empty string, which disables this check.

```yaml
configuration:
  AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT: '^docdb-'
```

This rule does not replace [Azure.DocumentDB.Name](Azure.DocumentDB.Name.md), which checks the resource provider's naming restrictions.

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
