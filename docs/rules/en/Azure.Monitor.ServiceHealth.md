---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Monitor
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Monitor.ServiceHealth.md
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

- [Service Health overview](https://docs.microsoft.com/en-us/azure/service-health/service-health-overview)
- [Create activity log alerts on service notifications](https://docs.microsoft.com/en-us/azure/service-health/alerts-activity-log-service-notifications)
