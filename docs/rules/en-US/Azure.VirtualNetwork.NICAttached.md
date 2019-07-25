---
severity: Awareness
category: Operations management
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VirtualNetwork.NICAttached.md
---

# Attach NIC or clean up

## SYNOPSIS

Network interfaces (NICs) should be attached.

## DESCRIPTION

NICs are deployed as resources separate from virtual machines. NICs that are not attached to a virtual machine perform no purpose.

## RECOMMENDATION

Consider cleaning up NICs that are not required to reduce management complexity. Also consider using Resource Groups to help manage the lifecycle of related resources together.
