---
reviewed: 2023-02-19
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Microsoft Defender for Cloud
resourceType: Microsoft.Security/pricings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Containers/
---

# Set Microsoft Defender for Containers to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for Containers.

## DESCRIPTION

Container-based workloads should be carefully monitored the following three core security aspects:

- Environment hardening : continuously assess your clusters to provide visibility into misconfigurations and threats.
- Runtime threat protection : to generate security alerts for suspicious activities.
- Vulnerability assessment : for images stored in ACR registries and running in Azure Kubernetes Service.

It is important to adopt a strategy to actively perform those three aspects.
One option for doing so is to use Microsoft Defender for Containers.

Defender for Cloud continuously assesses the configurations of your clusters.
If any misconfigurations is found, it generates security recommendations.
The recommendations available in the Recommendations page allow you to investigate and remediate issues.

Defender for Containers also provides real-time threat protection for your containerized environments.
If any suspicious activities is detected, Defender for Container generates an alert.
Threat protection at the cluster level is provided by the Defender agent and analysis of the Kubernetes audit logs.

Defender for Containers scans images on push, import, and recently pulled images.
Recently pulled images are scanned on a regular basis when they have been pulled within the last 30 days.
When scanned, the container image is pulled and executed in an isolated sandbox for scanning.
Any detected vulnerabilities are reported to Microsoft Defender for Cloud.

## RECOMMENDATION

Consider using Microsoft Defender for Containers to protect your container-based workloads.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for Containers:

- Set the `Standard` pricing tier for Microsoft Defender for Containers.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2024-01-01",
  "name": "Containers",
  "properties": {
    "pricingTier": "Standard"
  }
}
```

### Configure with Bicep

To enable Microsoft Defender for Containers:

- Set the `Standard` pricing tier for Microsoft Defender for Containers.

For example:

```bicep
resource defenderForContainers 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'Containers'
  properties: {
    pricingTier: 'Standard'
  }
}
```

<!-- external:avm avm/ptn/security/security-center containersTier -->

### Configure with Azure CLI

To enable Microsoft Defender for Containers:

- Set the `Standard` pricing tier for Microsoft Defender for Containers.

For example:

```bash
az security pricing create -n 'Containers' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for Containers:

- Set the `Standard` pricing tier for Microsoft Defender for Containers.

For example:

```powershell
Set-AzSecurityPricing -Name 'Containers' -PricingTier 'Standard'
```

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [Introduction to Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction)
- [Secure the images and run time](https://learn.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
- [Azure security baseline for Container Registry](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
