---
severity: Critical
pillar: Security
category: Security operations
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.CosmosDb/
---

# Set Microsoft Defender for Cosmos DB to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for Azure Cosmos DB.

## DESCRIPTION

Microsoft Defender for Azure Cosmos DB provides additional security insight for Azure Cosmos DB accounts.

Protection is provided by analyzing onboarded Cosmos DB accounts for unusual and potentially harmful attempts to access or exploit the accounts.
Which allows Microsoft Defender for Cloud to produce security alerts that are triggered when anomalies in activity occur.

Security alerts for onboarded Cosmos DB accounts shows up in Defender for Cloud with details of the suspicious activity and recommendations on how to investigate and remediate the threats.

Microsoft Defender for Cosmos DB can be enabled at the subscription level and by doing so ensures all Cosmos DB accounts in the subscription will be protected, including future ones.

## RECOMMENDATION

Consider using Microsoft Defender for Azure Cosmos DB to provide additional security for Azure Cosmos DB accounts.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for Azure Cosmos DB accounts:

- Set the `Standard` pricing tier for Microsoft Defender for Azure Cosmos DB.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "CosmosDbs",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Microsoft Defender for Azure Cosmos DB accounts:

- Set the `Standard` pricing tier for Microsoft Defender for Azure Cosmos DB.

For example:

```bicep
resource defenderForCosmosDb 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'CosmosDbs'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

To enable Microsoft Defender for Azure Cosmos DB accounts:

- Set the `Standard` pricing tier for Microsoft Defender for Azure Cosmos DB.

For example:

```bash
az security pricing create -n 'CosmosDbs' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for Azure Cosmos DB accounts:

- Set the `Standard` pricing tier for Microsoft Defender for Azure Cosmos DB.

For example:

```powershell
Set-AzSecurityPricing -Name 'CosmosDbs' -PricingTier 'Standard'
```

## NOTES

Microsoft Defender for Azure Cosmos DB is currently available only for the API for NoSQL.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Azure Cosmos DB](https://learn.microsoft.com/azure/defender-for-cloud/concept-defender-for-cosmos)
- [Enable Microsoft Defender for Azure Cosmos DB](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-enable-cosmos-protections)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Azure Cosmos DB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-cosmos-db-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
