---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: App Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppService.PHPVersion.md
---

# Use a newer PHP runtime version

## SYNOPSIS

Configure applications to use newer PHP runtime versions.

## DESCRIPTION

Within a App Service app, the version of PHP runtime used to run application/ site code is configurable.
Older versions of PHP may not use the latest security features.

## RECOMMENDATION

Consider updating the site to use a newer PHP runtime version.

## LINKS

- [Set PHP Version](https://docs.microsoft.com/azure/app-service/configure-language-php?pivots=platform-linux#set-php-version)
