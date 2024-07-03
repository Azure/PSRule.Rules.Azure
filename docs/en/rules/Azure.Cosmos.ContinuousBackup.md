---
severity: Important
pillar: Reliability
category: RE:06 Data partitioning
resource: Cosmos DB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.ContinuousBackup/
---

# Continuous backup

## SYNOPSIS

Cosmos DB has continuous backup configured.

## DESCRIPTION

Continuous backup for Azure Cosmos DB captures changes to the data in real-time, ensuring that you always have the most up-to-date backup. Data can be restored to any point in time within the retention period, offering flexibility and precision in data recovery.

Data can be restored to any point in time within the retention period.

Benefits of continuous backup:

- Accidental Write or Delete Recovery: Quickly recover from unintended changes within a container.
-	Comprehensive Restoration: Restore deleted accounts, databases, or containers.
-	Regional Flexibility: Restore data into any region where backups existed at the desired restore point.
- Ease of Use: Restore data directly through the Azure portal without needing support requests.

Continuous backup involves additional costs, so it is recommended for mission-critical applications with frequent data changes.

Check the documentation below for important information and limitations.

## RECOMMENDATION

Consider configuring Azure Cosmos DB with continuous backup mode for enhanced data protection and easier recovery.

## EXAMPLES

### Configure with Azure template

To configure continuous backup for Cosmos DB:

- Configure the `properties.backupPolicy` object.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2024-05-15",
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
    ],
     "backupPolicy": {
        "type": "Continuous", 
        "continuousModeProperties": {
        "tier": "Continuous7Days"
        }
     }
  }
}
```

### Configure with Bicep

To configure continuous backup for Cosmos DB:

- Configure the `properties.backupPolicy` object.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
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
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous30Days'
      }
    }
  }
}
```

## NOTES

Azure Cosmos DB API for Cassandra does not support continuous backup mode currently.

## LINKS

- [RE:06 Data partitioning](https://learn.microsoft.com/azure/well-architected/reliability/partition-data)
- [Continuous backup with point-in-time restore in Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/continuous-backup-restore-introduction)
- [Azure deployment reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts)
