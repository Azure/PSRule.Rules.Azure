---
severity: Important
pillar: Operational Excellence
category: Configuration
resource: Network Security Group
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.NSG.DenyAllInbound.md
---

# Avoid denying all inbound traffic

## SYNOPSIS

Avoid denying all inbound traffic.

## DESCRIPTION

Network Security Groups can be configured to block all network traffic inbound to a virtual machine.

Blocking all inbound traffic into a virtual machine will fail load balancer health probes and other required traffic.

Inbound network traffic can be whitelisted by including allow rules above deny all inbound rule by specifying a lower priority number.
Rules with a lower priority number will be process first.

## RECOMMENDATION

Deny all inbound rules should not use priority 100.
The lowest configurable priority is 100, meaning that whitelisted network traffic rules can not be placed before the deny all.

Consider whitelisting inbound network traffic as required.
