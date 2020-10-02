---
severity: Awareness
pillar: Performance Efficiency
category: Application design
resource: App Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppService.ARRAffinity.md
ms-content-id: 3f07def6-6e5e-4f87-8b5d-3a0baf6631e5
---

# Disable Application Request Routing

## SYNOPSIS

Disable client affinity for stateless services.

## DESCRIPTION

Azure App Service apps use Application Request Routing (ARR) by default.
ARR uses a cookie to route subsequent client requests back to the same instance when an app is scaled to two or more instances.
This benefits stateful applications, which may hold session information in instance memory.

For stateless applications, disabling ARR allows Azure App Service more evenly distribute load.

## RECOMMENDATION

Azure App Service sites make use of Application Request Routing (ARR) by default.
Consider disabling ARR affinity for stateless applications.

## LINKS

- [Configure an App Service app](https://docs.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Overview of the performance efficiency pillar](https://docs.microsoft.com/azure/architecture/framework/scalability/overview)
- [Session affinity](https://docs.microsoft.com/azure/architecture/framework/scalability/app-design#session-affinity)
- [Performance efficiency checklist](https://docs.microsoft.com/azure/architecture/framework/scalability/performance-efficiency)
