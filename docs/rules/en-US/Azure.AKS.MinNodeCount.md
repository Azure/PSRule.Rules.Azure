---
severity: Important
category: Reliability
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AKS.MinNodeCount.md
---

# Azure.AKS.MinNodeCount

## SYNOPSIS

AKS clusters should have minimum number of nodes for failover and updates.

## DESCRIPTION

AKS clusters should have minimum number of nodes for failover and updates.

## RECOMMENDATION

Use at least three (3) agent nodes.

Consider deploying additional nodes as required to provide enough resiliency during nodes failures or planned maintenance.
