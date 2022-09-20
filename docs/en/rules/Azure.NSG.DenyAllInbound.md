---
severity: Important
pillar: Operational Excellence
category: Configuration
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.DenyAllInbound/
---

# Avoid denying all inbound traffic

## SYNOPSIS

Avoid denying all inbound traffic.

## DESCRIPTION

Network Security Groups can be configured to block all inbound network traffic.
Blocking all inbound traffic will fail load balancer health probes and other required traffic.

When using a custom deny all inbound rule, also add rules to allow permitted traffic.
To permit network traffic, add a custom allow rule with a lower priority number then the deny all rule.
Rules with a lower priority number will be processed first.
100 is the lowest priority number.

## RECOMMENDATION

Consider using a higher priority number for deny all rules to allow permitted traffic rules to be added.

## LINKS

- [Network security groups](https://docs.microsoft.com/azure/virtual-network/security-overview)
- [Virtual network service tags](https://docs.microsoft.com/azure/virtual-network/service-tags-overview)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)
