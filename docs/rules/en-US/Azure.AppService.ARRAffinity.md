---
severity: Awareness
category: Performance
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AppService.ARRAffinity.md
---

# Azure.AppService.ARRAffinity

## SYNOPSIS

Disable client affinity for stateless services.

## DESCRIPTION

Disable client affinity for stateless services.

## RECOMMENDATION

Azure App Service sites make use of Application Request Routing (ARR) by default.

Disable ARR affinity when not required.
