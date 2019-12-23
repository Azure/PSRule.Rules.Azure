---
severity: Awareness
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Automation.WebHookExpiry.md
ms-content-id: 7b8aa617-6278-42e4-b8ae-d9da6e3d8ade
---

# Azure.Automation.WebHookExpiry

## SYNOPSIS

Do not create webhooks with an expiry time greater than 1 year (default).

## DESCRIPTION

Do not create webhooks with an expiry time greater than 1 year (default).

## RECOMMENDATION

An expiry time of 1 year is the default for webhook creation. Webhooks should be programatically rotated at regular intervals - Microsoft recommends setting a shorter time than the default of 1 year. If authenticaton is required for a webhook consider implementing a preshared key in the header - or using an Azure Function.
