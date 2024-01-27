---
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Traffic Manager
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.TrafficManager.Endpoints/
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

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [What is Traffic Manager?](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview)
- [How Traffic Manager Works](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-how-it-works)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/trafficmanagerprofiles)
