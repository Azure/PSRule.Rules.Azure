---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Load Balancer
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.Probe/
---

# Use specific load balancer probe

## SYNOPSIS

Use a specific probe for web protocols.

## DESCRIPTION

A load balancer probe can be configured as TCP/ HTTP or HTTPS.

## RECOMMENDATION

Consider using a dedicated health check endpoint for HTTP or HTTPS health probes.

## LINKS

- [Load Balancer health probes](https://docs.microsoft.com/azure/load-balancer/load-balancer-custom-probe-overview)
- [Creating good health probes](https://learn.microsoft.com/azure/architecture/framework/resiliency/monitoring#creating-good-health-probes)
- [Health Endpoint Monitoring pattern](https://docs.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
