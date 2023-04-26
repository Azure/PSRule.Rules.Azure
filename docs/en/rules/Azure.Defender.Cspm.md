---
severity: Critical
pillar: Security
category: Security operations
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Cspm/
---

# Set Microsoft Defender Cloud Security Posture Management to the Standard plan

## SYNOPSIS

Enable Microsoft Defender Cloud Security Posture Management Standard plan.

## DESCRIPTION

Microsoft Defender Cloud Security Posture Management (CSPM) provides additional visibility across cloud environments to quickly detect configuration errors and remediate them through automation.
It does this by keeping constant eye on the security state of your cloud resources in different environments.

By enabling the Defender Cloud CSPM Standard plan, Microsoft Defender provides advanced posture management capabilities such as:

- Attack path analysis
- Cloud security explorer 
- Advanced threat hunting
- Security governance capabilities
- Tools to assess your security compliance with a wide range of benchmarks, regulatory standards, and any custom security policies required in your organization, industry, or region

Microsoft Defender Cloud Security Posture Management (CSPM) can be enabled at the subscription level.

## RECOMMENDATION

Consider using Microsoft Defender Cloud Security Posture Management (CSPM) Standard plan to provide additional visibility across cloud environments.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender Cloud Security Posture Management Standard plan:

- Set the `Standard` pricing tier for Microsoft Defender Cloud Security Posture Management.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "CloudPosture",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Microsoft Defender Cloud Security Posture Management Standard plan:

- Set the `Standard` pricing tier for Microsoft Defender Cloud Security Posture Management.

For example:

```bicep
resource defenderCspm 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'CloudPosture'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

TTo enable Microsoft Defender Cloud Security Posture Management Standard plan:

- Set the `Standard` pricing tier for Microsoft Defender Cloud Security Posture Management.

For example:

```bash
az security pricing create -n 'CloudPosture' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender Cloud Security Posture Management Standard plan:

- Set the `Standard` pricing tier for Microsoft Defender Cloud Security Posture Management.

For example:

```powershell
Set-AzSecurityPricing -Name 'CloudPosture' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources before deployed (pre-flight) and deployed (in-flight) to Azure.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Cloud Security Posture Management (CSPM)](https://learn.microsoft.com/azure/defender-for-cloud/concept-cloud-security-posture-management)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-dns-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
