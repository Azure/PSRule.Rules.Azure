---
severity: Critical
pillar: Security
category: Security operations
resource: Cosmos DB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.DefenderCloud/
---

# Enable Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Azure Cosmos DB.

## DESCRIPTION

Microsoft Defender for Azure Cosmos DB provides additional security insight for Azure Cosmos DB accounts.

Protection is provided by analyzing onboarded Cosmos DB accounts for unusual and potentially harmful attempts to access or exploit the accounts.
Which allows Microsoft Defender for Cloud to produce security alerts that are triggered when anomalies in activity occur.

Security alerts for onboarded Cosmos DB accounts shows up in Defender for Cloud with details of the suspicious activity and recommendations on how to investigate and remediate the threats.

Microsoft Defender for Cosmos DB can be enabled at the resource level, but the general recommandation is to enable it at the subscription level and by doing so ensures all Cosmos DB accounts in the subscription will be protected, including future ones. However, enabling it at resource level can be done to protect a specific Azure Cosmos DB account.

## RECOMMENDATION

Consider using Microsoft Defender for Azure Cosmos DB to provide additional security insights for Azure Cosmos DB accounts.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for Azure Cosmos DB accounts:

- Deploy a `Microsoft.DBforMySQL/servers/securityAlertPolicies` sub-resource (extension resource).
- Set the `properties.isEnabled` property to `true`.

For example:

```json
{
  "type": "Microsoft.Security/advancedThreatProtectionSettings",
  "apiVersion": "2019-01-01",
  "scope": "[format('Microsoft.DocumentDB/databaseAccounts/{0}', parameters('accountName'))]",
  "name": "current",
  "properties": {
    "isEnabled": true
  },
  "dependsOn": [
    "cosmosDbAccount"
  ]
}
```

### Configure with Bicep

To enable Microsoft Defender for Azure Cosmos DB accounts:

- Deploy a `Microsoft.DBforMySQL/servers/securityAlertPolicies` sub-resource (extension resource).
- Set the `properties.isEnabled` property to `true`.

For example:

```bicep
resource defenderForCosmosDb 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  scope: cosmosDbAccount
  name: 'current'
  properties: {
    isEnabled: true
  }
}
```

## NOTES

Microsoft Defender for Azure Cosmos DB is currently available only for the NoSQL API. When Microsoft Defender for Cosmos DB is enabled at the subscription level, the resource level enablement has no effect as it will be handled by the plan at the subscription level.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Azure Cosmos DB](https://learn.microsoft.com/azure/defender-for-cloud/concept-defender-for-cosmos)
- [Enable Microsoft Defender for Azure Cosmos DB](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-enable-cosmos-protections)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Azure Cosmos DB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline)
- [DP-2: Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/advancedthreatprotectionsettings)
