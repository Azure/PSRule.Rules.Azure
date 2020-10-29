---
severity: Important
pillar: Security
category: Encryption
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.ContentTrust.md
---

# Use trusted container images

## SYNOPSIS

Use container images signed by a trusted image publisher.

## DESCRIPTION

Azure Container Registry (ACR) content trust enables pushing and pulling of signed images.
Signed images provides additional assurance that they have been built on a trusted source.

## RECOMMENDATION

Consider enabling content trust on registries, clients, and sign container images.

## LINKS

- [Content trust in Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-content-trust)
- [Follow best practices for container security](https://docs.microsoft.com/azure/architecture/framework/security/applications-services#follow-best-practices-for-container-security)
- [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/)
