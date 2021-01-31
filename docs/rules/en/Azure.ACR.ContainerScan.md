---
severity: Critical
pillar: Security
category: Applications and services
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.ContainerScan.md
---

# Scan ACR container images

## SYNOPSIS

Enable vulnerability scanning for container images.

## DESCRIPTION

A potential risk with container-based workloads is un-patched security vulnerabilities in:

- Operating System base images.
- Frameworks and runtime dependencies used by application code.

It is important to adopt a strategy to actively scan images for security vulnerabilities.
One option for scanning container images is to use Azure Defender for container registries.
Azure Defender uses Qualys to scan images each time a container image is pushed to the registry.

Azure Defender scans container images on push, on import, and recently pulled images.
Recently pulled images are scanned on a regular basis when they have been pulled within the last 30 days.
When scanned, Azure Defender pulls and runs the container image in an isolated sandbox for scanning.
Any detected vulnerabilities are reported to Security Center.

Container image vulnerability scanning with Azure Defender:

- Is currently only available for Linux-hosted ACR registries.
- The container registry must be accessible by Azure Defender.
Network access can not be restricted by firewall, Service Endpoints, or Private Endpoints.
- Is supported in commercial clouds.
Is not currently supported in sovereign or national clouds (e.g. US Gov, China Gov, etc.).

## RECOMMENDATION

Consider using Azure Defender to scan for security vulnerabilities in container images.

## EXAMPLES

### Enable with Azure CLI

```bash
az security pricing create -n 'ContainerRegistry' --tier 'standard'
```

### Enable with Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'ContainerRegistry' -PricingTier 'Standard'
```

## NOTES

This rule applies when analyzing resources deployed to Azure.

## LINKS

- [Introduction to Azure Defender for container registries](https://docs.microsoft.com/azure/security-center/defender-for-container-registries-introduction)
- [Container security in Security Center](https://docs.microsoft.com/azure/security-center/container-security)
- [Secure the images and run time](https://docs.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
- [Follow best practices for container security](https://docs.microsoft.com/azure/architecture/framework/security/applications-services#follow-best-practices-for-container-security)
