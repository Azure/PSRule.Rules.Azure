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

- [What TLS versions are supported by Azure Front Door Service?](https://docs.microsoft.com/azure/frontdoor/front-door-faq#what-tls-versions-are-supported-by-azure-front-door-service)
