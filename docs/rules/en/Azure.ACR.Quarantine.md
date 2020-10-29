---
severity: Important
pillar: Security
category: Applications and services
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.Quarantine.md
---

# Use container image quarantine

## SYNOPSIS

Enable container image quarantine, scan, and mark images as verified.

## DESCRIPTION

Image quarantine is a configurable option for Azure Container Registry (ACR).
When enabled, images pushed to the container registry are not available by default.
Each image must be verified and marked as `Passed` before it is available to pull.

To verify container images, integrate with an external security tool that supports this feature.

## RECOMMENDATION

Consider configuring a security tool to implement the image quarantine pattern.
Enable image quarantine on the container registry to ensure each image is verified before use.

## NOTES

Image quarantine for Azure Container Registry is currently in preview.

## LINKS

- [How do I enable automatic image quarantine for a registry?](https://docs.microsoft.com/azure/container-registry/container-registry-faq#how-do-i-enable-automatic-image-quarantine-for-a-registry)
- [Quarantine Pattern](https://github.com/Azure/acr/tree/main/docs/preview/quarantine)
- [Secure the images and run time](https://docs.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
- [Follow best practices for container security](https://docs.microsoft.com/azure/architecture/framework/security/applications-services#follow-best-practices-for-container-security)
