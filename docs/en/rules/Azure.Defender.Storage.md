---
reviewed: 2023-18-05
severity: Critical
pillar: Security
category: Tools
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Storage/
---

# Configure Microsoft Defender for Storage to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for Storage.

## DESCRIPTION

Microsoft Defender for Storage provides additional security for storage accounts.

Protection is provided by:

- Continuously analyzing data and control plane logs from protected storage accounts.
- Malicious scanning by performing a full malware scan on uploaded content in near real time, leveraging Microsoft Defender Antivirus capabilities.
- Sensitive data threat detection by a smart sampling method to find resources with sensitive data.

Which allows Microsoft Defender for Cloud to discover and mitigate potential threats.

Security findings for onboarded storage accounts shows up in Defender for Cloud with details of the security threats with contextual information.

Microsoft Defender for Storage can be enabled at the subscription level and by doing so ensures all storage accounts in the subscription will be protected, including future ones.

## RECOMMENDATION

Consider using Microsoft Defender for Storage to protect your data hosted in storage accounts.

## EXAMPLES

### Configure with Azure template

To enable Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage and set the `DefenderForStorageV2` sub plan.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2023-01-01",
  "name": "StorageAccounts",
  "properties": {
    "pricingTier": "Standard",
    "subPlan": "DefenderForStorageV2",
    "extensions": [
      {
        "name": "OnUploadMalwareScanning",
        "isEnabled": "True",
        "additionalExtensionProperties": {
          "CapGBPerMonthPerStorageAccount": "5000"
        }
      },
      {
        "name": "SensitiveDataDiscovery",
        "isEnabled": "True"
      }
    ]
  }
}
```

### Configure with Bicep

To enable Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage and set the `DefenderForStorageV2` sub plan.

For example:

```bicep
resource defenderForStorage 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: 'Standard'
    subPlan: 'DefenderForStorageV2'
    extensions: [
      {
        name: 'OnUploadMalwareScanning'
        isEnabled: 'True'
        additionalExtensionProperties: {
          CapGBPerMonthPerStorageAccount: '5000'
        }
      }
      {
        name: 'SensitiveDataDiscovery'
        isEnabled: 'True'
      }
    ]
  }
}
```

### Configure with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'StorageAccounts' -PricingTier 'Standard' -SubPlan 'DefenderForStorageV2'
```

## NOTES

The `DefenderForStorageV2` sub plan represents the new Defender for Storage plan which offers several new benefits that aren't included in the classic plan.
The new plan includes more advanced capabilities that can help improve the security of the data and help prevent malicious file uploads, sensitive data exfiltration, and data corruption.
Some features within the new plan is still in preview, but these are configurable.

Currently only the `Blob Storage`, `Azure Files` and `Azure Data Lake Storage Gen2` service is supported by Defender for Storage.

## LINKS

- [Azure security monitoring tools](https://learn.microsoft.com/azure/well-architected/security/monitor-tools)
- [Storage security guide](https://learn.microsoft.com/azure/storage/blobs/security-recommendations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Storage](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-storage-introduction)
- [Migrate from Defender for Storage (classic) to the new plan](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-storage-classic-migrate)
- [Enable and configure Microsoft Defender for Storage](https://learn.microsoft.com/azure/storage/common/azure-defender-storage-configure)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Storage](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline)
- [DP-2: Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
