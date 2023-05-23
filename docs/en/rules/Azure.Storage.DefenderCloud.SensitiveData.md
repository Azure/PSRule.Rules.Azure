---
severity: Critical
pillar: Security
category: Data protection
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.DefenderCloud.SensitiveData/
---

# Sensitive data threat detection

## SYNOPSIS

Enable sensitive data threat detection in Microsoft Defender for Storage.

## DESCRIPTION

Microsoft Defender for Storage provides additional security for storage accounts.

One of the features in the Defender for Storage service is sensitive data threat detection that is powered by the Sensitive Data Discovery engine that uses a smart sampling method to find storage accounts with sensitive data.

The service is integrated with Microsoft Purview's sensitive information types (SITs) and classification labels.

The sensitive data threat detection capability helps teams identify and prioritize data security incidents for faster response times. Defender for Storage alerts include findings of sensitivity scanning and indications of operations that have been performed on resources containing sensitive data.

This can be useful when:

- Reduce the likelihood of data breaches
- Detect exposure events
- Detect suspicious activities on resources containing sensitive data 

When enabling sensitive data threat detection, the sensitive data categories include built-in sensitive information types (SITs) in the default list of Microsoft Purview. This will affect the alerts received from Defender for Storage, storage or containers that are found with these SITs are marked as containing sensitive data.

It is also possible to customize the Data Sensitivity Discovery for a organization, you can create custom sensitive information types (SITs) and connect to your organizational settings.

Sensitive data threat detection in Microsoft Defender for Storage can be enabled at the resource level. However, the general recommandation is to enable it at the subscription level and by doing so ensures all storage accounts in the subscription will be protected, including future ones. Defender for Storage settings on each storage account is inherited by the subscription level settings.

It is also worth to mention that the resouce level enablement can be useful when:

- Override subscription level settings to configure specific storage accounts with custom sensitive data threat detection settings that differ from the settings configured at the subscription level.

## RECOMMENDATION

Consider enabling sensitive data threat detection using Microsoft Defender for Storage on the Storage Account.
Alternatively, enable Sensitive data threat detection for all Storage Accounts within a subscription.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.sensitiveDataDiscovery.isEnabled` property to `true`.

For example:

```json
{
    "type": "Microsoft.Security/DefenderForStorageSettings",
    "apiVersion": "2022-12-01-preview",
    "name": "current",
    "properties": {
        "sensitiveDataDiscovery": {
            "isEnabled": true
        },
        "overrideSubscriptionLevelSettings": false
    },
    "scope": "[resourceId('Microsoft.Storage/storageAccounts', parameters('StorageAccountName'))]"
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Deploy a `Microsoft.Security/DefenderForStorageSettings` sub-resource (extension resource).
- Set the `properties.sensitiveDataDiscovery.isEnabled` property to `true`.

For example:

```bicep
resource defenderForStorageSettings 'Microsoft.Security/DefenderForStorageSettings@2022-12-01-preview' = {
  name: 'current'
  scope: storageAccount
  properties: {
    sensitiveDataDiscovery: {
      isEnabled: true
    }
    overrideSubscriptionLevelSettings: false
  }
}
```

## NOTES

This feature is currently in preview.

Sensitive data threat detection is not supported for storage accounts with public network access set to disabled. Not all services within storage accounts are currently supported.

- When the plan is already enabled at the subscription level and the resource level override property `overrideSubscriptionLevelSettings` value is `false`, the resource level enablement will be ignored and the subscription level (plan) will still be used.
- If the override property `overrideSubscriptionLevelSettings` value is `true`, the resource level enablement will be honored and a dedicated plan will be configured for the storage account.
- If there is no plan at the subcription level, the resource level enablement will be honored and a dedicated plan will be configured for the storage account.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
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
