---
severity: Critical
pillar: Security
category: Virtual Machine
resource: Microsoft Defender for Containers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.Servers/
---

# Name of rule

## SYNOPSIS

Enable Microsoft Defender for Servers.

## DESCRIPTION

{{ A detailed description of the rule }}

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
resource defenderForContainerRegistry 'Microsoft.Security/pricings@2022-03-01' = {
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

- [Monitor Azure resources in Microsoft Defender for Cloud](https://docs.microsoft.com/azure/architecture/framework/security/monitor-resources#virtual-machines)
- [Introduction to Microsoft Defender for Containers](https://docs.microsoft.com/azure/defender-for-cloud/defender-for-servers-introduction)
- [Azure Monitor agent auto-provisioning](https://docs.microsoft.comkj/azure/defender-for-cloud/auto-deploy-azure-monitoring-agent)
