---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Virtual Network
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VNET.PeerState.md
---

# VNET peer is not connected

## SYNOPSIS

VNET peering connections must be connected.

## DESCRIPTION

When peering virtual networks, a peering connection must be established from both virtual networks.

## RECOMMENDATION

Consider removing peering connections that are not longer required or complete peering connections.
