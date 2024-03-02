---
reviewed: 2024-03-02
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.DefenderCloud/
---

# Enable Microsoft Defender

## SYNOPSIS

Enable Microsoft Defender for Storage for storage accounts.

## DESCRIPTION

Microsoft Defender for Storage analyzes data and control plane logs from protected Storage Accounts.
Which allows Microsoft Defender for Cloud to surface findings with details of the security threats and contextual information.

Additionally, Microsoft Defender for Storage provides security extensions to analyze data stored within Storage Accounts:

- Anti-malware scanning of uploaded content in near real time, leveraging Microsoft Defender Antivirus capabilities.
- Sensitive data threat detection to find resources with sensitive data.

Microsoft Defender for Storage can be enabled on a per subscription or per resource basis.
Enabling at the subscription level is recommended because it protects current and future Storage Accounts.
However, enabling at the resource level may be preferred for specific Storage Account to apply custom settings.

## RECOMMENDATION

Consider using Microsoft Defender for Storage to protect your data hosted in storage accounts.
Additionally, consider using Microsoft Defender for Storage to protect all storage accounts within a subscription.

## EXAMPLES

### Configure with Azure template

To deploy storage accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.isEnabled` property to `true`.

For example:

```json
{
  "type": "Microsoft.Security/defenderForStorageSettings",
  "apiVersion": "2022-12-01-preview",
  "scope": "[format('Microsoft.Storage/storageAccounts/{0}', parameters('name'))]",
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
  "dependsOn": [
    "[resourceId('Microsoft.Storage/storageAccounts', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy storage accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.isEnabled` property to `true`.

For example:

```bicep
resource defenderForStorageSettings 'Microsoft.Security/defenderForStorageSettings@2022-12-01-preview' = {
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

The following limitations currently apply for Microsoft Defender for Storage:

- Sensitive data discovery are preview features.
- Storage types supported are `Blob Storage`, `Azure Files` and `Azure Data Lake Storage Gen2`.
  Other storage types are not supported.
- When Microsoft Defender is enabled at subscription and resource level, the subscription configuration will take priority.
  To override settings on a Storage Account, set the `properties.overrideSubscriptionLevelSettings` property to `true`.
- If there is no plan at the subscription level, Microsoft Defender for Storage can be configured without an override.

### Rule configuration

<!-- module:config rule AZURE_STORAGE_DEFENDER_PER_ACCOUNT -->

This rule is not processed by default because configuration at the subscription level is recommended.
To enable this rule, set the `AZURE_STORAGE_DEFENDER_PER_ACCOUNT` configuration value to `true`.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Storage](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-storage-introduction)
- [Enable and configure Microsoft Defender for Storage](https://learn.microsoft.com/azure/storage/common/azure-defender-storage-configure)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Storage](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline)
- [DP-2: Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
