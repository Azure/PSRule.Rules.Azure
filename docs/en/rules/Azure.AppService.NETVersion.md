---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.NETVersion/
---

# Use a newer .NET Framework version

## SYNOPSIS

Configure applications to use newer .NET Framework versions.

## DESCRIPTION

Within a App Service app, the version of .NET Framework used to run application/ site code is configurable.
Older versions of .NET Framework may not use the latest security features.

## RECOMMENDATION

Consider updating the site to use a newer .NET Framework version.

## LINKS

- [Set .NET Framework runtime version](https://docs.microsoft.com/azure/app-service/configure-language-dotnet-framework#set-net-framework-runtime-version)
