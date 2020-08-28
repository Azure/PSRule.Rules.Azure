---
severity: Important
pillar: Security
category: Network security and containment
resource: Network Security Group
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.NSG.LateralTraversal.md
---

# Limit lateral traversal

## SYNOPSIS

Deny outbound management connections from non-management hosts.

## DESCRIPTION

Network Security Groups (NSGs) allow virtual machines to be segmented from each other by enforcing access rules for all traffic in/ out of a virtual machine.

This micro-segmentation approach provides a control to reduce lateral movement between hosts within Azure, a virtual network or an individual subnet.

Typically, a subset of trusted hosts such as privileged access workstations, bastion hosts or jump boxes will be used for management.
Management protocols originating from application workload hosts should be blocked.

## RECOMMENDATION

Consider configuring NSGs rules to block outbound management traffic from non-management hosts.
