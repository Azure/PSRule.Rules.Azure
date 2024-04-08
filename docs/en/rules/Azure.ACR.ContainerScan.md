---
reviewed: 2021-11-13
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ContainerScan/
---

# Scan Container Registry images

## SYNOPSIS

Enable vulnerability scanning for container images.

## DESCRIPTION

A potential risk with container-based workloads is un-patched security vulnerabilities in:

- Operating System base images.
- Frameworks and runtime dependencies used by application code.

It is important to adopt a strategy to actively scan images for security vulnerabilities.
One option for scanning container images is to use Microsoft Defender for container registries.
Microsoft Defender for container registries scans each container image pushed to the registry.

Microsoft Defender for container registries scans images on push, import, and recently pulled images.
Recently pulled images are scanned on a regular basis when they have been pulled within the last 30 days.
When scanned, the container image is pulled and executed in an isolated sandbox for scanning.
Any detected vulnerabilities are reported to Microsoft Defender for Cloud.

Container image vulnerability scanning with Microsoft Defender for container registries:

- Is currently only available for Linux-hosted ACR registries.
- The container registry must be accessible by Microsoft Defender for Container registries.
  Network access can not be restricted by firewall, Service Endpoints, or Private Endpoints.
- Is supported in commercial clouds.
  Is not currently supported in sovereign or national clouds (e.g. US Gov, China Gov, etc.).

## RECOMMENDATION

Consider using Microsoft Defender for Cloud to scan for security vulnerabilities in container images.

## EXAMPLES

### Configure with Azure template

To enable container image scanning:

- Set the `Standard` pricing tier for Microsoft Defender for container registries.

For example:

```json
{
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2018-06-01",
    "name": "ContainerRegistry",
    "properties": {
        "pricingTier": "Standard"
    }
}
```

### Configure with Bicep

To enable container image scanning:

- Set the `Standard` pricing tier for Microsoft Defender for container registries.

For example:

```bicep
resource defenderForContainerRegistry 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ContainerRegistry'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configure with Azure CLI

```bash
az security pricing create -n 'ContainerRegistry' --tier 'standard'
```

### Configure with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'ContainerRegistry' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [Introduction to Microsoft Defender for container registries](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-container-registries-introduction)
- [Container security in Microsoft Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction)
- [Secure the images and run time](https://learn.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
