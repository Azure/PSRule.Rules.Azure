---
severity: Critical
pillar: Security
category: Network security and containment
resource: Logic App
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.LogicApp.LimitTrigger.md
---

# Limit Logic App HTTP request triggers

## SYNOPSIS

Limit HTTP request trigger access to trusted IP addresses.

## DESCRIPTION

When a Logic App uses a HTTP request trigger by default any source IP address can trigger the workflow.
Logic Apps can be configured to limit the IP addresses that are accepted to trigger the workflow.

## RECOMMENDATION

Consider limiting Logic Apps with HTTP request triggers to trusted IP addresses.

## LINKS

- [Secure access and data in Azure Logic Apps](https://docs.microsoft.com/azure/logic-apps/logic-apps-securing-a-logic-app)
- [Azure security baseline for Logic Apps](https://docs.microsoft.com/azure/logic-apps/security-baseline#network-security)
