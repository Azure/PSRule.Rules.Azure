---
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.OssRdb/
---

# Set Microsoft Defender for open-source relational databases to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for open-source relational databases.

## DESCRIPTION

Microsoft Defender for open-source relational databases provides additional security for open-source relational databases.

The following open-source relational databases are supported:

- Azure Database for PostgreSQL
- Azure Database for MySQL
- Azure Database for MariaDB

Protection is provided by analyzing onboarded databases for unusual and potentially harmful attempts to access or exploit databases.
Which allows Microsoft Defender for Cloud to produce security alerts that are triggered when anomalies in activity occur.

Security alerts for onboarded databases shows up in Defender for Cloud with details of the suspicious activity and recommendations on how to investigate and remediate the threats.

Microsoft Defender for open-source relational databases can be enabled at the subscription level and by doing so ensures all supported databases in the subscription will be protected, including future ones.

## RECOMMENDATION

Consider using Microsoft Defender for for open-source relational databases to provide additional security for open-source relational databases.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for open-source relational databases:

- Set the `Standard` pricing tier for Microsoft Defender for open-source relational databases.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2024-01-01",
  "name": "OpenSourceRelationalDatabases",
  "properties": {
    "pricingTier": "Standard"
  }
}
```

### Configure with Bicep

To enable Microsoft Defender for open-source relational databases:

- Set the `Standard` pricing tier for Microsoft Defender for open-source relational databases.

For example:

```bicep
resource defenderForOssRdb 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'OpenSourceRelationalDatabases'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

To enable Microsoft Defender for open-source relational databases:

- Set the `Standard` pricing tier for Microsoft Defender for open-source relational databases.

For example:

```bash
az security pricing create -n 'OpenSourceRelationalDatabases' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for open-source relational databases:

- Set the `Standard` pricing tier for Microsoft Defender for open-source relational databases.

For example:

```powershell
Set-AzSecurityPricing -Name 'OpenSourceRelationalDatabases' -PricingTier 'Standard'
```

## NOTES

Microsoft Defender for open-source relational databases is currently available only for the single server deployment model for PostgreSQL and the single server deployment model for MySQL. For PostgreSQL, MySQL and MariaDB `General Purpose` and `Memory Optimized` tiers are required in order to be protected.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for open-source relational databases](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-introduction)
- [Enable Defender for OSS RDBs](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-databases-usage)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Azure Database for PostgreSQL - Single Server](https://learn.microsoft.com/security/benchmark/azure/baselines/postgresql-security-baseline)
- [Azure security baseline for Azure Database for MySQL - Single Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-security-baseline)
- [Azure security baseline for Azure Database for MariaDB](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mariadb-security-baseline)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
