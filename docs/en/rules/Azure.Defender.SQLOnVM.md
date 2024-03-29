---
severity: Critical
pillar: Security
category: Security operations
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.SQLOnVM/
---

# Configure Microsoft Defender for SQL Servers on machines to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for SQL servers on machines.

## DESCRIPTION

SQL databases are used to store critical and strategic assets for your company and should be carefully secured.
Microsoft Defender for SQL Servers on machines represents a single go-to location to manage security capabilities.

Enabling Defender for SQL automatically enables vulnerability Assessment for your SQL databases hosted in a VM.
It discovers, tracks, and provides guidance to remediate potential database vulnerabilities.

Enabling at subscription level doesn't protect all your SQL servers.
A Log Analytics agent must be deployed on the machine and the Log Analytics workspace must have Defender for SQL enabled.

## RECOMMENDATION

Consider using Microsoft Defender for SQL Servers on machines to protect your SQL servers running on VMs.

## EXAMPLES

### Configure with Azure template

To enable Defender for SQL servers on machines:

- Set the `Standard` pricing tier for Microsoft Defender for SQL servers on machines.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "SqlServerVirtualMachines",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Defender for SQL servers on machines:

- Set the `Standard` pricing tier for Microsoft Defender for SQL servers on machines.

For example:

```bicep
resource defenderForSQLOnVM 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'SqlServerVirtualMachines'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

```bash
az security pricing create -n 'SqlServerVirtualMachines' --tier 'standard'
```

### Configure with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'SqlServerVirtualMachines' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Monitor Azure resources in Microsoft Defender for Cloud](https://learn.microsoft.com/azure/architecture/framework/security/monitor-resources#virtual-machines)
- [Introduction to Microsoft Defender for SQL Servers on machines](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-sql-usage)
- [Security considerations for SQL Server on Azure Virtual Machines](https://learn.microsoft.com/azure/azure-sql/virtual-machines/windows/security-considerations-best-practices?view=azuresql)
- [Azure Security Benchmark - Data protection](https://learn.microsoft.com/security/benchmark/azure/security-controls-v2-data-protection)
