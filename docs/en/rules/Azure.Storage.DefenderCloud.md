---
severity: Critical
pillar: Security
category: Data protection
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.DefenderCloud/
---

# Enable Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Storage for storage accounts.

## DESCRIPTION

Microsoft Defender for Storage analyzes data and control plane logs from protected Storage Sccounts.
Which allows Microsoft Defender for Cloud to surface findings with details of the security threats and contextual information.

Additionally, Microsoft Defender for Storage provides security extensions to analyze data stored within Storage Accounts:

- Antimalware scanning of uploaded content in near real time, leveraging Microsoft Defender Antivirus capabilities.
- Sensitive data threat detection to find resources with sensitive data.

Microsoft Defender for Storage can be enabled on a per subscription or per resource basis.
Enabling at the subscription level is recommended because it protects current and future Storage Accounts.
However, enabling at the resource level may be prefered for specific Storage Account to apply custom settings.

## RECOMMENDATION

Consider using Microsoft Defender for Storage to protect your data hosted in storage accounts.
Alternatively, use Microsoft Defender for Storage for all storage accounts within a subscription.

## EXAMPLES

### Configure with Azure template

To deploy storage accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.isEnabled` property to `true`.

For example:

```json
{
    "type": "Microsoft.Security/DefenderForStorageSettings",
    "apiVersion": "2022-12-01-preview",
    "name": "current",
    "properties": {
        "isEnabled": true,
        "malwareScanning": {
            "onUpload": {
                "isEnabled": true,
                "capGBPerMonth": 5000
            }
        },
        "sensitiveDataDiscovery": {
            "isEnabled": true
        },
        "overrideSubscriptionLevelSettings": false
    },
    "scope": "[resourceId('Microsoft.Storage/storageAccounts', parameters('StorageAccountName'))]"
}
```

### Configure with Bicep

To deploy storage accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.isEnabled` property to `true`.

For example:

```bicep
resource defenderForStorageSettings 'Microsoft.Security/DefenderForStorageSettings@2022-12-01-preview' = {
  name: 'current'
  scope: storageAccount
  properties: {
    isEnabled: true
    malwareScanning: {
      onUpload: {
        isEnabled: true
        capGBPerMonth: 5000
      }
    }
    sensitiveDataDiscovery: {
      isEnabled: true
    }
    overrideSubscriptionLevelSettings: false
  }
}
```

## NOTES

Some of the features included in Defender for Storage is in preview.

Currently only the `Blob Storage`, `Azure Files` and `Azure Data Lake Storage Gen2` service is supported by Defender for Storage.

- When the plan is already enabled at the subscription level and the resource level override property `overrideSubscriptionLevelSettings` value is `false`, the resource level enablement will be ignored and the subscription level (plan) will still be used.
- If the override property `overrideSubscriptionLevelSettings` value is `true`, the resource level enablement will be honored and a dedicated plan will be configured for the storage account.
- If there is no plan at the subcription level, the resource level enablement will be honored and a dedicated plan will be configured for the storage account.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Storage](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-storage-introduction)
- [Enable and configure Microsoft Defender for Storage](https://learn.microsoft.com/azure/storage/common/azure-defender-storage-configure)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Storage](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline)
- [DP-2: Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
