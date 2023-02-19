---
reviewed: 2023-02-19
severity: Critical
pillar: Security
category: Security operations
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Dns/
---

# Set Microsoft Defender for DNS to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for DNS.

## DESCRIPTION

Microsoft Defender for DNS provides additional protection for virtual networks and resources.
It does this by monitoring Azure-provided DNS for suspicious and anomalous activity.
By analyzing telemetry for DNS, Microsoft Defender for DNS can detect and alert on persistent threats such as:

- Data exfiltration from your Azure resources using DNS tunneling.
- Malware communicating with command and control servers.
- DNS attacks - communication with malicious DNS resolvers.
- Communication with domains used for malicious activities such as phishing and crypto mining.

Microsoft Defender for DNS can be enabled at the subscription level.

## RECOMMENDATION

Consider using Microsoft Defender for DNS to provide additional protection to virtual network and resources.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for DNS:

- Set the `Standard` pricing tier for Microsoft Defender for DNS.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "Dns",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Microsoft Defender for DNS:

- Set the `Standard` pricing tier for Microsoft Defender for DNS.

For example:

```bicep
resource defenderForDns 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Dns'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

To enable Microsoft Defender for DNS:

- Set the `Standard` pricing tier for Microsoft Defender for DNS.

For example:

```bash
az security pricing create -n 'Dns' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for DNS:

- Set the `Standard` pricing tier for Microsoft Defender for DNS.

For example:

```powershell
Set-AzSecurityPricing -Name 'Dns' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Security operations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/monitor-security-operations)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for DNS](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-dns-introduction)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Azure DNS](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-dns-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-dns-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)
