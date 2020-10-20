---
severity: Awareness
pillar: Performance Efficiency
category: Application design
resource: App Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppService.HTTP2.md
---

# Use HTTP/2 connections for App Service apps

## SYNOPSIS

Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency.

## DESCRIPTION

Azure App Service has native support for HTTP/2, but by default it is disabled.
HTTP/2 offers a number of improvements over HTTP/1.1, including:

- Connections are fully multiplexed, instead of ordered and blocking.
- Connections are reused, reducing connection establishment overhead.
- Headers are compressed to reduce overhead.

## RECOMMENDATION

Consider using HTTP/2 for Azure Services apps to improve protocol efficiency.

## LINKS

- [Configure an App Service app](https://docs.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Performance efficiency checklist](https://docs.microsoft.com/azure/architecture/framework/scalability/performance-efficiency)
