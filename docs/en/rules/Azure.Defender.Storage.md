---
severity: Critical
pillar: Security
category: Data protection
resource: Microsoft Defender for Storage
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Storage/
---

# Configure Microsoft Defender for Storage to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for Storage.

## DESCRIPTION

Storage Accounts can be subject to many security threats.
Data corruption, malicious exposure of data, data exfiltration, unauthorized access are only a few.

Microsoft Defender for Storage provides protection against unusual and potential harmful access to your Storage Accounts.
Based on Microsoft Threat Intelligence, it continuously monitor the telemetry stream to raise alerts when needed.

All those alerts come along with investigation steps, remediation actions, and security recommendations.

Defender for Storage doesn't access the Storage account data and has no impact on its performance.

## RECOMMENDATION

Consider using Microsoft Defender for Storage to protect your data hosted in Storage Accounts.

## EXAMPLES

### Configure with Azure template

To enable Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "StorageAccounts",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage.

For example:

```bicep
resource defenderForStorage 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

```bash
az security pricing create -n 'StorageAccounts' --tier 'standard'
```

### Configure with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'StorageAccounts' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Storage security guide](https://docs.microsoft.com/azure/storage/blobs/security-recommendations?toc=%2Fazure%2Fsecurity%2Ffundamentals%2Ftoc.json&bc=%2Fazure%2Fsecurity%2Fbreadcrumb%2Ftoc.json)
- [Introduction to Microsoft Defender for Storage](https://docs.microsoft.com/azure/defender-for-cloud/defender-for-storage-introduction)
- [Microsoft Threat Intelligence](https://www.microsoft.com/en-us/insidetrack/microsoft-uses-threat-intelligence-to-protect-detect-and-respond-to-threats)
