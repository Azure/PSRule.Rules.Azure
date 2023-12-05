---
reviewed: 2022-01-22
severity: Important
pillar: Cost Optimization
category: CO:14 Consolidation
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.Usage/
---

# Remove unused Service Bus namespaces

## SYNOPSIS

Regularly remove unused resources to reduce costs.

## DESCRIPTION

Billing starts for a Standard or Premium Service Bus namespace after it is provisioned.
To to receive messages you must first create at least one queue or topic.
Namespaces without any queues or topics are considered unused.

## RECOMMENDATION

Consider removing Service Bus namespaces that are not used.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [CO:14 Consolidation](https://learn.microsoft.com/azure/well-architected/cost-optimization/consolidation)
- [Design review checklist for Cost Optimization](https://learn.microsoft.com/azure/well-architected/cost-optimization/checklist)
- [Pricing](https://azure.microsoft.com/pricing/details/service-bus/)
