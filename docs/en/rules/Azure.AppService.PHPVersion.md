---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.PHPVersion/
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
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteconfig-object)
