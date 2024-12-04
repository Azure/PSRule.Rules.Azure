---
severity: Important
pillar: Reliability
category: RE:10 Monitoring and alerting
resource: Monitor
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Monitor.ServiceHealth/
---

# Alert on service events

## SYNOPSIS

Configure Service Health alerts to notify administrators.

## DESCRIPTION

Azure provides events and can alert administrators when one of the following occurs in your subscriptions:

- Service issue
- Planned maintenance
- Health advisories
- Security advisory

## RECOMMENDATION

Consider configuring an alert to notify administrators when services you are using are potentially impacted.

## LINKS

- [RE:10 Monitoring and alerting](https://learn.microsoft.com/azure/well-architected/reliability/monitoring-alerting-strategy)
- [Service Health overview](https://learn.microsoft.com/azure/service-health/service-health-overview)
- [Create activity log alerts on service notifications](https://learn.microsoft.com/azure/service-health/alerts-activity-log-service-notifications)
