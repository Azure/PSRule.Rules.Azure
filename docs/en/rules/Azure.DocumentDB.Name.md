---
reviewed: 2026-11-23
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.Name/
---

# Azure DocumentDB cluster names must meet naming requirements

## SYNOPSIS

Azure DocumentDB cluster names should meet resource naming requirements.

## DESCRIPTION

Azure DocumentDB cluster names must be between 3 and 40 characters long.
Names can contain lowercase letters, numbers, and single hyphens separating alphanumeric segments.
Names must start and end with a lowercase letter or number and cannot contain consecutive hyphens.
Validating names before deployment reduces avoidable deployment failures.

## RECOMMENDATION

Consider validating cluster names against the resource provider's naming constraints.

## EXAMPLES

### Configure with Azure template

Use a valid name, such as `docdb-prod-001`.
Declare `administratorPassword` as a `secureString` parameter.

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

This rule does not check global name availability or uniqueness.
For organizational naming conventions, configure [Azure.DocumentDB.Naming](Azure.DocumentDB.Naming.md).

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
