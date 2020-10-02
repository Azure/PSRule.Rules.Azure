---
severity: Important
pillar: Performance Efficiency
category: Application design
resource: App Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppService.AlwaysOn.md
---

# Use App Service Always On

## SYNOPSIS

Configure Always On for App Service apps.

## DESCRIPTION

Azure App Service apps are automatically unloaded when there's no traffic.
Unloading apps reduces resource consumption when apps share a single App Services Plan.
After an app have been unloaded, the next web request will trigger a cold start of the app.

A cold start of the app can cause a noticeable performance issues and request timeouts.

Continuous WebJobs or WebJobs triggered with a CRON expression must use always on to start.

The Always On feature is implemented by the App Service load balancer,
periodically sending requests to the application root.

## RECOMMENDATION

Consider enabling Always On for each App Services app.

## LINKS

- [Configure an App Service app](https://docs.microsoft.com/azure/app-service/configure-common#configure-general-settings)
