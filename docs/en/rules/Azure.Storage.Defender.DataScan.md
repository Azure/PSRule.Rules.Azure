---
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts,Microsoft.Security/defenderForStorageSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.Defender.DataScan/
---

# Sensitive data threat detection

## SYNOPSIS

Enable sensitive data threat detection in Microsoft Defender for Storage.

## DESCRIPTION

Sensitive data threat detection is an additional security feature for Microsoft Defender for Storage.
When enabled Defender for Storage provides alerts when sensitive data is discovered.

The sensitive data threat detection capability helps teams:

- Identity where sensitive data is stored.
- Detect possible security incidents resulting is data exposure.

When enabling sensitive data threat detection, the sensitive data categories include built-in sensitive information types (SITs) in the default list of Microsoft Purview.
It is possible to customize the Data Sensitivity Discovery for a organization, by creating custom sensitive information types (SITs).

Sensitive data threat detection in Microsoft Defender for Storage can be enabled at the subscription level and by doing so ensures all storage accounts in the subscription will be protected, including future ones.

When overriding sensitive data threat detection on individual Storage Account it is possible to configure custom sensitive data threat detection settings that differ from the settings configured at the subscription level.

## RECOMMENDATION

Consider enabling sensitive data threat detection using Microsoft Defender for Storage on the Storage Account.
Additionally, consider enabling sensitive data threat detection for all Storage Accounts within a subscription.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.sensitiveDataDiscovery.isEnabled` property to `true`.

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

To deploy Storage Accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.sensitiveDataDiscovery.isEnabled` property to `true`.

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

This feature is currently in preview.

The following limitations currently apply for Microsoft Defender for Storage:

- Only Storage Accounts with public network access set to enabled are supported.
- Not all storage services within Storage Accounts are currently supported.
- When Microsoft Defender is enabled at subscription and resource level, the subscription configuration will take priority.
  To override settings on a Storage Account, set the `properties.overrideSubscriptionLevelSettings` property to `true`.
- If there is no plan at the subscription level, Microsoft Defender for Storage can be configured without an override.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Sensitive data threat detection in Defender for Storage](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-storage-data-sensitivity)
- [Support and prerequisites for data-aware security posture](https://learn.microsoft.com/azure/defender-for-cloud/concept-data-security-posture-prepare)
- [Overview of Microsoft Defender for Storage](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-storage-introduction)
- [Enable and configure Microsoft Defender for Storage](https://learn.microsoft.com/azure/storage/common/azure-defender-storage-configure)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Storage](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline)
- [DP-2: Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
