---
severity: Critical
pillar: Security
category: Encryption
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.MinTLS/
---

# Front Door minimum TLS

## SYNOPSIS

Front Door should reject TLS versions older then 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Front Door accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Front Door lets you disable outdated protocols and enforce TLS 1.2.
By default, a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [What TLS versions are supported by Azure Front Door Service?](https://docs.microsoft.com/azure/frontdoor/front-door-faq#what-tls-versions-are-supported-by-azure-front-door-service)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors/frontendendpoints)
