---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.MinNodeCount.md
ms-content-id: 320afea5-5c19-45ad-b9a5-c1a63ae6e114
---

# Azure.AKS.MinNodeCount

## SYNOPSIS

AKS clusters should have minimum number of nodes for failover and updates.

## DESCRIPTION

Kubernetes clusters should have minimum number of three (3) nodes for high availability and planned maintenance.

## RECOMMENDATION

Use at least three (3) agent nodes.
Consider deploying additional nodes as required to provide enough resiliency during nodes failures or planned maintenance.
