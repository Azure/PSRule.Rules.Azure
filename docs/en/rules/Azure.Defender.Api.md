---
severity: Critical
pillar: Security
category: Security operations
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Api/
---

# Set Microsoft Defender for APIs to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for APIs.

## DESCRIPTION

Microsoft Defender for APIs provides additional security for APIs published in Azure API Management.

Protection is provided by analyzing onboarded APIs.
Which allows Microsoft Defender for Cloud to produce security findings.

The inventory and security findings for onboarded APIs is reviewed in the Defender for Cloud API Security dashboard.

These security findings includes API recommendations and runtime threats.

Defender for APIs can be enabled together with the Defender CSPM plan, offering further capabilities.

Microsoft Defender for APIs can be enabled at the subscription level.

## RECOMMENDATION

Consider using Microsoft Defender for APIs to provide additional security for APIs published in Azure API Management.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for APIs:

- Set the `Standard` pricing tier for Microsoft Defender for APIs.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "Api",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Microsoft Defender for APIs:

- Set the `Standard` pricing tier for Microsoft Defender for APIs.

For example:

```bicep
resource defenderForApi 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Api'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

To enable Microsoft Defender for APIs:

- Set the `Standard` pricing tier for Microsoft Defender for APIs.

For example:

```bash
az security pricing create -n 'Api' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for APIs:

- Set the `Standard` pricing tier for Microsoft Defender for APIs.

For example:

```powershell
Set-AzSecurityPricing -Name 'Api' -PricingTier 'Standard'
```

## NOTES

Microsoft Defender for APIs is a preview feature.
Currently only REST APIs published in Azure API Management is supported. Not all regions are supported.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for APIs](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-apis-introduction)
- [Support and prerequisites for Defender for APIs](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-apis-prepare)
- [Onboard Defender for APIs](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-apis-deploy)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for API Management](https://learn.microsoft.com/security/benchmark/azure/baselines/api-management-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/api-management-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
