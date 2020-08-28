---
severity: Awareness
pillar: Security
category: Identity and access management
resource: Automation Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Automation.WebHookExpiry.md
ms-content-id: 7b8aa617-6278-42e4-b8ae-d9da6e3d8ade
---

# Use short lived web hooks

## SYNOPSIS

Do not create webhooks with an expiry time greater than 1 year (default).

## DESCRIPTION

Do not create webhooks with an expiry time greater than 1 year (default).

## RECOMMENDATION

An expiry time of 1 year is the default for webhook creation.
Webhooks should be programmatically rotated at regular intervals - Microsoft recommends setting a shorter time than the default of 1 year.
If authentication is required for a webhook consider implementing a pre-shared key in the header - or using an Azure Function.
