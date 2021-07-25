---
severity: Critical
pillar: Security
category: Data protection
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.UseHTTPS/
author: BernieWhite
ms-date: 2021/07/25
---

# Expose frontend HTTP endpoints over HTTPS

## SYNOPSIS

Application Gateways should only expose frontend HTTP endpoints over HTTPS.

## DESCRIPTION

Application Gateways support HTTP and HTTPS endpoints for backend and frontend traffic.
When using frontend HTTP (80) endpoints, traffic between client and Application Gateway is not encrypted.

Unencrypted communication could allow disclosure of information to an un-trusted party.

## RECOMMENDATION

Consider configuring Application Gateways to only expose HTTPS endpoints.
For client applications such as progressive web apps, consider redirecting HTTP traffic to HTTPS.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Create an application gateway with HTTP to HTTPS redirection using the Azure portal](https://docs.microsoft.com/azure/application-gateway/redirect-http-to-https-portal)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/applicationgateways)
