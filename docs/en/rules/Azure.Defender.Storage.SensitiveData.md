---
severity: Critical
pillar: Security
category: Data protection
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Storage.SensitiveData/
---

# Sensitive data threat detection

## SYNOPSIS

Enable sensitive data threat detection in Microsoft Defender for Storage.

## DESCRIPTION

Microsoft Defender for Storage provides additional security for storage accounts.

One of the features in the Defender for Storage service is sensitive data threat detection that is powered by the Sensitive Data Discovery engine that uses a smart sampling method to find storage accounts with sensitive data.

The service is integrated with Microsoft Purview's sensitive information types (SITs) and classification labels.

The sensitive data threat detection capability helps teams identify and prioritize data security incidents for faster response times. Defender for Storage alerts include findings of sensitivity scanning and indications of operations that have been performed on resources containing sensitive data.

Some benefits:

- Reduce the likelihood of data breaches
- Detect exposure events
- Detect suspicious activities on resources containing sensitive data 

When enabling sensitive data threat detection, the sensitive data categories include built-in sensitive information types (SITs) in the default list of Microsoft Purview. This will affect the alerts received from Defender for Storage, storage or containers that are found with these SITs are marked as containing sensitive data.

It is also possible to customize the Data Sensitivity Discovery for a organization, you can create custom sensitive information types (SITs) and connect to your organizational settings.

Sensitive data threat detection in Microsoft Defender for Storage can be enabled at the subscription level and by doing so ensures all storage accounts in the subscription will be protected, including future ones.

## RECOMMENDATION

Consider using sensitive data threat detection in Microsoft Defender for Storage.

## EXAMPLES

### Configure with Azure template

To enable sensitive data threat detection in Microsoft Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage and set the `DefenderForStorageV2` sub plan.
- Configure an `SensitiveDataDiscovery` extension.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "StorageAccounts",
    "properties": {
        "pricingTier": "Standard",
        "subPlan": "DefenderForStorageV2",
        "extensions": [
            {
                "name": "SensitiveDataDiscovery",
                "isEnabled": "True",
            }
        ]
    }
}
```

### Configure with Bicep

To enable sensitive data threat detection in Microsoft Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage and set the `DefenderForStorageV2` sub plan.
- Configure an `SensitiveDataDiscovery` extension.

For example:

```bicep
resource defenderForStorage 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: 'Standard'
    subPlan: 'DefenderForStorageV2'
    extensions: [
      {
        name: 'SensitiveDataDiscovery'
        isEnabled: 'True'
      }
    ]
  }
}
```

## NOTES

This feature is currently in preview.

The `DefenderForStorageV2` sub plan represents the new Defender for Storage plan which offers several new benefits that aren't included in the classic plan, such as sensitive data threat detection.

Sensitive data threat detection is not supported for storage accounts with public network access set to disabled. Not all services within storage accounts are currently supported.

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
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
