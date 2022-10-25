---
severity: Critical
pillar: Security
category: Review and remediate
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

- [Review and remediate recommendations](https://learn.microsoft.com/azure/architecture/framework/security/monitor-remediate#review-and-remediate-recommendations)
- [Introduction to Azure Defender for container registries](https://docs.microsoft.com/azure/security-center/defender-for-container-registries-introduction)
- [Overview of Microsoft Defender for Containers](https://docs.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction)
- [Secure the images and run time](https://docs.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
