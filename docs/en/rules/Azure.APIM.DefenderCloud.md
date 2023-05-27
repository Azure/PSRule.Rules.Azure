---
severity: Critical
pillar: Security
category: Security operations
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.DefenderCloud/
---

# Onboard Defender for APIs

## SYNOPSIS

APIs published in Azure API Management should be onboarded to Microsoft Defender for APIs.

## DESCRIPTION

Microsoft Defender for APIs provides additional security for APIs published in Azure API Management.
Protection is provided by analyzing onboarded APIs.

Which allows Microsoft Defender for Cloud to produce security findings.
These security findings includes API recommendations and runtime threats.

The inventory and security findings for onboarded APIs is reviewed in the Defender for Cloud API Security dashboard.
Defender for APIs can be enabled together with the Defender CSPM plan, offering further capabilities.

To use Microsoft Defender for APIs:

1. Enable the plan at the subscription level.
2. Onboard each API to Microsoft Defender for APIs.

## RECOMMENDATION

Consider onboarding APIs published in Azure API Management to Microsoft Defender for APIs.

## EXAMPLES

### Configure with Azure template

To deploy API Management APIs that pass this rule:

- Deploy a `Microsoft.Security/apiCollections` sub-resource (extension resource).
- Set the `name` property to the name as the API.

For example:

```json
{
  "type": "Microsoft.Security/apiCollections",
  "apiVersion": "2022-11-20-preview",
  "scope": "[format('Microsoft.ApiManagement/service/{0}', parameters('apiManagementServiceName'))]",
  "name": "[parameters('apiName')]"
}
```

### Configure with Bicep

To deploy API Management APIs that pass this rule:

- Deploy a `Microsoft.Security/apiCollections` sub-resource (extension resource).
- Set the `name` property to the name as the API.

For example:

```bicep
resource apiManagementService 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apiManagementServiceName
}

resource onboardDefender 'Microsoft.Security/apiCollections@2022-11-20-preview' = {
  name: apiName
  scope: apiManagementService
}
```

## NOTES

Microsoft Defender for APIs is a preview feature.

Onboarding APIs to Defender for APIs is a two-step process:

1. Enable the Defender for APIs plan for the subscription.
2. Onboard unprotected APIs in API Management instances.
  
Currently only REST APIs published in Azure API Management is supported. Defender for APIs currently doesn't onboard APIs that are exposed using the API Management self-hosted gateway or managed using API Management workspaces. The rule can therefore emit false results as it doesn't currently filter on self-hosted gateways or managed using workspaces. Not all regions are supported.

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
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/apicollections)
