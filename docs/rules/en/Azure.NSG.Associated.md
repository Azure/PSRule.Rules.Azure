---
severity: Awareness
category: Operations management
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.NSG.Associated.md
---

# Associate NSGs or clean up

## SYNOPSIS

Network Security Groups (NSGs) should be associated.

## DESCRIPTION

NSGs basic stateful firewalls that are deployed as separate resources and can be associated to network interfaces or subnets.
NSGs that are not associated with a network interface or subnet perform no purpose.

## RECOMMENDATION

Consider cleaning up NSGs that are not required to reduce management complexity.
Also consider using Resource Groups to help manage the lifecycle of related resources together.
