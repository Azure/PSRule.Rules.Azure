---
reviewed: 2023-02-19
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Microsoft Defender for Cloud
resourceType: Microsoft.Security/pricings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Arm/
---

# Set Microsoft Defender for ARM to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for Azure Resource Manager (ARM).

## DESCRIPTION

Microsoft Defender for ARM provides additional protection for control plane activities.
It does this by detecting suspicious activities such as disabling security features or attempts at lateral movement.

Protection is provided by analyzing telemetry from Azure Resource Manager operations.
Which allows Microsoft Defender for Cloud to detect anomalous activities regardless of the tool used to perform the operation.
For example: Azure CLI, Azure Portal, PowerShell, REST API, Terraform, etc.

When anomalous activities occur, Microsoft Defender for ARM shows alerts to relevant members of your organization.
These alerts include the details of the suspicious activity and recommendations on how to investigate and remediate threats.

Microsoft Defender for ARM can be enabled at the subscription level.

## RECOMMENDATION

Consider using Microsoft Defender for Resource Manager to provide additional protection to control plane activities.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for Resource Manager:

- Set the `Standard` pricing tier for Microsoft Defender for Resource Manager.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2024-01-01",
  "name": "Arm",
  "properties": {
    "pricingTier": "Standard"
  }
}
```

### Configure with Bicep

To enable Microsoft Defender for Resource Manager:

- Set the `Standard` pricing tier for Microsoft Defender for Resource Manager.

For example:

```bicep
resource defenderForArm 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'Arm'
  properties: {
    pricingTier: 'Standard'
  }
}
```

<!-- external:avm avm/ptn/security/security-center armPricingTier -->

### Configure with Azure CLI

To enable Microsoft Defender for Resource Manager:

- Set the `Standard` pricing tier for Microsoft Defender for Resource Manager.

For example:

```bash
az security pricing create -n 'Arm' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for Resource Manager:

- Set the `Standard` pricing tier for Microsoft Defender for Resource Manager.

For example:

```powershell
Set-AzSecurityPricing -Name 'Arm' -PricingTier 'Standard'
```

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Resource Manager](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-resource-manager-introduction)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Azure Resource Manager](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-resource-manager-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-resource-manager-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
