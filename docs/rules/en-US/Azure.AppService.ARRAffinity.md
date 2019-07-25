---
severity: Awareness
category: Performance
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AppService.ARRAffinity.md
ms-content-id: 3f07def6-6e5e-4f87-8b5d-3a0baf6631e5
---

# Azure.AppService.ARRAffinity

## SYNOPSIS

Disable client affinity for stateless services.

## DESCRIPTION

Disable client affinity for stateless services.

## RECOMMENDATION

Azure App Service sites make use of Application Request Routing (ARR) by default.

Disable ARR affinity when not required.
