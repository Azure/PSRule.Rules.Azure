---
reviewed: 2022/01/22
severity: Important
pillar: Cost Optimization
category: Reports
resource: Event Hub
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.Usage/
---

# Remove unused Event Hub namespaces

## SYNOPSIS

Regularly remove unused resources to reduce costs.

## DESCRIPTION

Billing starts for an Event Hub namespace after it is provisioned.
To receive events in a Event Hub namespace, you must first create an Event Hub.
Namespaces without any Event Hubs are considered unused.

## RECOMMENDATION

Consider removing Event Hub namespaces that are not used.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Generate cost reports](https://learn.microsoft.com/azure/architecture/framework/cost/monitor-reports)
- [Pricing](https://azure.microsoft.com/pricing/details/event-hubs/)
