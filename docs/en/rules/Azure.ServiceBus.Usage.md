---
reviewed: 2022/01/22
severity: Important
pillar: Cost Optimization
category: Reports
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.Usage/
---

# Remove unused Service Bus namespaces

## SYNOPSIS

Regularly remove unused resources to reduce costs.

## DESCRIPTION

Billing starts for a Standard or Premium Service Bus namespace after it is provisioned.
To to recieve messages you must first create at least one queue or topic.
Namespaces without any queues or topics are considered unused.

## RECOMMENDATION

Consider removing Service Bus namespaces that are not used.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Generate cost reports](https://docs.microsoft.com/azure/architecture/framework/cost/monitor-reports)
- [Pricing](https://azure.microsoft.com/pricing/details/service-bus/)
