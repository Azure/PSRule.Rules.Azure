---
severity: Important
pillar: Security
category: Security configuration
resource: App Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppService.RemoteDebug.md
---

# Disable App Service remote debugging

## SYNOPSIS

Disable remote debugging on App Service apps when not in use.

## DESCRIPTION

Remote debugging can be enabled on apps running within Azure App Services.

To enable remote debugging, App Service allows connectivity to additional ports.
While access to remote debugging ports is authenticated, the attack service for an app is increased.

## RECOMMENDATION

Consider disabling remote debugging when not in use.

## LINKS

- [Configure general settings](https://docs.microsoft.com/azure/app-service/configure-common#configure-general-settings)
