---
severity: Critical
pillar: Security
category: Virtual Machine
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Servers/
---

# Configure Microsoft Defender for Servers to the Standard tier and P2

## SYNOPSIS

Enable Microsoft Defender for Servers.

## DESCRIPTION

Microsoft Defender for Servers automatically deploys an agent into your Windows and Linux machines to protect them.

With the unified integration of Microsoft Defender for Endpoint (MDE) you benefit from features like:

- Threat and vulnerability management : to discover vulnerabilities and misconfigurations in real time
- Security Policy and Regulatory Compliance integration
- Qualys integration for real time identification of vulnerabilities without any license needed
- Threat detection at OS level, network layer and control plane
- Just-in-time (JIT) access : to reduce your machine's surface attack
- And more.

## RECOMMENDATION

Consider using Microsoft Defender for Servers P2 to protect your virtual machines.

## EXAMPLES

### Configure with Azure template

To enable Defender for Servers:

- Set the `Standard` pricing tier for Microsoft Defender for Servers and set the `P2` sub plan.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "VirtualMachines",
    "properties": {
        "pricingTier": "Standard",
        "subPlan": "P2"
    }
}
```

### Configure with Bicep

To enable Defender for Servers:

- Set the `Standard` pricing tier for Microsoft Defender for Servers and set the `P2` sub plan.

For example:

```bicep
resource defenderForServers 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: 'Standard',
    subPlan: 'P2'
  }
}
```

### Configure with Azure CLI

```bash
az security pricing create -n 'VirtualMachines' --tier 'standard'
```

### Configure with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'VirtualMachines' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Monitor Azure resources in Microsoft Defender for Cloud](https://learn.microsoft.com/azure/architecture/framework/security/monitor-resources#virtual-machines)
- [Introduction to Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-servers-introduction)
- [Azure Monitor agent auto-provisioning](https://learn.microsoft.com/azure/defender-for-cloud/auto-deploy-azure-monitoring-agent)
