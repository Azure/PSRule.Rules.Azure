---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Application Gateway
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppGw.MinSku.md
---

# Use production Application Gateway SKU

## SYNOPSIS

Application Gateway should use a minimum instance size of Medium.

## DESCRIPTION

An Application Gateway is offered in different versions v1 and v2.
When deploying an Application Gateway v1, three different instance sizes are available: Small, Medium and Large.

Application Gateway v2, Standard_v2 and WAF_v2 SKUs don't offer different instance sizes.

## RECOMMENDATION

Application Gateways using v1 SKUs should be deployed with an instance size of Medium or Large.
Small instance sizes are intended for development and testing scenarios.

## LINKS

- [Azure Application Gateway sizing](https://docs.microsoft.com/en-us/azure/application-gateway/overview#sizing)
