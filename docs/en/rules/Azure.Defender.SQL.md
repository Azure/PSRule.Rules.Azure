---
reviewed: 2023-02-19
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.SQL/
---

# Configure Microsoft Defender for SQL to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for SQL servers.

## DESCRIPTION

SQL databases are used to store critical and strategic assets for your company and should be carefully secured.
Microsoft Defender for SQL represents a single go-to location to manage security capabilities.

Enabling Defender for SQL automatically enables the following advanced SQL security capabilities:

- Vulnerability Assessment: discover, track, and provide guidance to remediate potential database vulnerabilities.
- Advanced Threat Protection: continuous monitoring of your databases, detection of suspect activities and more.

When enable at subscription level, all databases in Azure SQL Database and Azure SQL Managed Instance are protected.

## RECOMMENDATION

Consider using Microsoft Defender for SQL to protect your SQL databases.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for SQL:

- Set the `Standard` pricing tier for Microsoft Defender for SQL.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2024-01-01",
  "name": "SqlServers",
  "properties": {
    "pricingTier": "Standard"
  }
}
```

### Configure with Bicep

To enable Microsoft Defender for SQL:

- Set the `Standard` pricing tier for Microsoft Defender for SQL.

For example:

```bicep
resource defenderForSQL 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'SqlServers'
  properties: {
    pricingTier: 'Standard'
  }
}
```

<!-- external:avm avm/ptn/security/security-center sqlServersPricingTier -->

### Configure with Azure CLI

To enable Microsoft Defender for SQL:

- Set the `Standard` pricing tier for Microsoft Defender for SQL.

For example:

```bash
az security pricing create -n 'SqlServers' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for SQL:

- Set the `Standard` pricing tier for Microsoft Defender for SQL.

For example:

```powershell
Set-AzSecurityPricing -Name 'SqlServers' -PricingTier 'Standard'
```

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [Azure SQL Database and security](https://learn.microsoft.com/azure/architecture/framework/services/data/azure-sql-database-well-architected-framework#azure-sql-database-and-security)
- [Introduction to Microsoft Defender for SQL](https://learn.microsoft.com/azure/azure-sql/database/azure-defender-for-sql?view=azuresql)
- [Azure security baseline for Azure SQL](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-sql-security-baseline)
- [DP-2: Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/mcsb-data-protection#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-sql-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
