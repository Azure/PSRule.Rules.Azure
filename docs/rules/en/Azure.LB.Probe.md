---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Load Balancer
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.LB.Probe.md
---

# Use specific load balancer probe

## SYNOPSIS

Use a specific probe for web protocols.

## DESCRIPTION

A load balancer probe can be configured as TCP/ HTTP or HTTPS.

## RECOMMENDATION

Consider using a dedicated health check endpoint for HTTP or HTTPS health probes.
