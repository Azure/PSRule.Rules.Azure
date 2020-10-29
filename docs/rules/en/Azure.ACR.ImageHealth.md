---
severity: Critical
pillar: Security
category: Applications and services
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.ImageHealth.md
---

# Remove vulnerable container images

## SYNOPSIS

Remove container images with known vulnerabilities.

## DESCRIPTION

When Azure Defender for container registries is enabled, Azure Defender scans container images.
Container images are scanned for known vulnerabilities and marked as healthy or unhealthy.
Vulnerable container images should not be used.

## RECOMMENDATION

Consider using removing container images with known vulnerabilities.

## NOTES

This rule applies when analyzing resources deployed to Azure.

## LINKS

- [Introduction to Azure Defender for container registries](https://docs.microsoft.com/azure/security-center/defender-for-container-registries-introduction)
- [Container security in Security Center](https://docs.microsoft.com/azure/security-center/container-security)
- [Secure the images and run time](https://docs.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
- [Follow best practices for container security](https://docs.microsoft.com/azure/architecture/framework/security/applications-services#follow-best-practices-for-container-security)
