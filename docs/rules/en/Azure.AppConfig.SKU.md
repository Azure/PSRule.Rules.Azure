---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: App Configuration
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppConfig.SKU.md
---

# Use production App Configuration SKU

## SYNOPSIS

App Configuration should use a minimum size of Standard.

## DESCRIPTION

App Configuration is offered in two different SKUs; Free, and Standard.
Standard includes additional features, increases scalability, and 99.9% SLA.
The Free SKU does not include a SLA.

## RECOMMENDATION

Consider upgrading App Configuration instances to Standard.
Free instances are intended only for early development and testing scenarios.

## LINKS

- [App Configuration pricing](https://azure.microsoft.compricing/details/app-configuration/)
