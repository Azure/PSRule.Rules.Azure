---
severity: Important
pillar: Reliability
category: RE:05 Redundancy
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

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Load Balancer health probes](https://learn.microsoft.com/azure/load-balancer/load-balancer-custom-probe-overview)
- [Health Endpoint Monitoring pattern](https://learn.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
