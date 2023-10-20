---
severity: Critical
pillar: Security
category: Tools
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Storage.SensitiveData/
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

To enable sensitive data threat detection in Microsoft Defender for Storage:

- Set the `Standard` pricing tier for Microsoft Defender for Storage and set the `DefenderForStorageV2` sub plan.
- Configure an `SensitiveDataDiscovery` extension.

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

## NOTES

This feature is currently in preview.

The `DefenderForStorageV2` sub plan represents the new Defender for Storage plan which offers several new benefits that aren't included in the classic plan, such as sensitive data threat detection.

Sensitive data threat detection is not supported for storage accounts with public network access set to disabled.
Not all services within storage accounts are currently supported.

## LINKS

- [Azure security monitoring tools](https://learn.microsoft.com/azure/well-architected/security/monitor-tools)
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
