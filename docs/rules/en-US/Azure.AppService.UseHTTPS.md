---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AppService.UseHTTPS.md
ms-content-id: b26053bc-db4a-487a-8fb1-11c438c8d493
---

# Azure.AppService.UseHTTPS

## SYNOPSIS

Use HTTPS only. Disable HTTP when not required.

## DESCRIPTION

Use HTTPS only. Disable HTTP when not required.

## RECOMMENDATION

If access through HTTP is not required consider disabling HTTP. When HTTP is enabled, both HTTP and HTTPS will be accepted by Azure App Service.
