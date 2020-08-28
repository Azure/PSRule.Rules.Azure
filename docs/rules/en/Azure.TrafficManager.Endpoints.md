---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Traffic Manager
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.TrafficManager.Endpoints.md
---

# Use at least two Traffic Manager endpoints

## SYNOPSIS

Traffic Manager should use at lest two enabled endpoints.

## DESCRIPTION

Traffic Manager is a DNS service that enables you to distribute traffic to improve availability and responsiveness.
Traffic is distributed across endpoints, which can be located in different availability zones and regions.

When only one enabled endpoint exists, routing for high availability and/ or responsiveness is not possible.

## RECOMMENDATION

Consider adding additional endpoints or enabling disabled endpoints.
Also consider, using endpoints deployed across different regions to provide high availability.

## LINKS

- [What is Traffic Manager?](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview)
- [How Traffic Manager Works](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-how-it-works)
