---
severity: Critical
pillar: Security
category: Data protection
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.AppServices/
---

# Configure Microsoft Defender for App Services to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for App Service.

## DESCRIPTION

Many attacks are performed first by probing web applications to find and exploit weaknesses.
It is crucial to secure your applications, even while running in PaaS services like App Service.

Microsoft Defender for App Service identifies attacks over App Service thanks to cloud scale data analysis.
It offers:

- Hardening capabilities for your App Services through assessments and security recommendations.
- Detection of threats at different levels such as underlying VMs, internal logs, I/O to your App Service, etc.
- Protection against common attack patterns like MITRE ATT&CK or even dangling DNS.

The solution is particularly efficient as it can can identify attack methodologies applying to multiple targets.
The log data and the infrastructure together are used to enhance Defender for App Service globally.

## RECOMMENDATION

Consider using Microsoft Defender for App Service to protect your web apps and APIs.

## EXAMPLES

### Configure with Azure template

To enable Defender for App Service:

- Set the `Standard` pricing tier for Microsoft Defender for App Service.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2022-03-01",
    "name": "AppServices",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable Defender for App Service:

- Set the `Standard` pricing tier for Microsoft Defender for App Service.

For example:

```bicep
resource defenderForAppService 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

```bash
az security pricing create -n 'AppServices' --tier 'standard'
```

### Configure with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'AppServices' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Securing applications and PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments)
- [Introduction to Microsoft Defender for App Service](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-app-service-introduction)
- [App Service security best practices](https://learn.microsoft.com/azure/security/fundamentals/paas-applications-using-app-services)
