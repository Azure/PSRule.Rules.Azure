---
reviewed: 2024-03-02
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Storage.DataScan/
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

Consider using sensitive data threat detection in Microsoft Defender for Storage for all storage accounts in the subscription.

## EXAMPLES

### Configure with Azure template

To enable sensitive data threat detection in Microsoft Defender for Storage:

- Set the `properties.pricingTier` property to `Standard`.
- Set the `properties.subPlan` property to `DefenderForStorageV2`.
- Configure settings for the `SensitiveDataDiscovery` extension.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2024-01-01",
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

- Set the `properties.pricingTier` property to `Standard`.
- Set the `properties.subPlan` property to `DefenderForStorageV2`.
- Configure settings for the `SensitiveDataDiscovery` extension.

For example:

```bicep
resource defenderForStorage 'Microsoft.Security/pricings@2024-01-01' = {
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

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Microsoft Defender for Storage should be enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Security%20Center/MDC_Microsoft_Defender_For_Storage_Full_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/640d2586-54d2-465f-877f-9ffc1d2109f4`
- [Configure Microsoft Defender for Storage to be enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Security%20Center/MDC_Microsoft_Defender_For_Storage_Full_Deploy.json)
  `/providers/Microsoft.Authorization/policyDefinitions/cfdc5972-75b3-4418-8ae1-7f5c36839390`

## NOTES

This feature is currently in preview.

Sensitive data threat detection is only available in the `DefenderForStorageV2` sub plan for Defender for Storage,
which offers new features that aren't included in the classic plan.

Not all services and blob types within storage accounts are currently supported.
See limitations for more information.

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
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
