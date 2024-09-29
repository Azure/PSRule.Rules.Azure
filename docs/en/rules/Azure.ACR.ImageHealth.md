---
severity: Critical
pillar: Security
category: SE:02 Secured development lifecycle
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ImageHealth/
---

# Remove vulnerable container images

## SYNOPSIS

Remove container images with known vulnerabilities.

## DESCRIPTION

When Microsoft Defender for container registries is enabled, Microsoft Defender scans container images.
Container images are scanned for known vulnerabilities and marked as healthy or unhealthy.
Vulnerable container images should not be used.

## RECOMMENDATION

Consider using removing container images with known vulnerabilities.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Introduction to Azure Defender for container registries](https://learn.microsoft.com/azure/security-center/defender-for-container-registries-introduction)
- [Overview of Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction)
- [Secure the images and run time](https://learn.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
