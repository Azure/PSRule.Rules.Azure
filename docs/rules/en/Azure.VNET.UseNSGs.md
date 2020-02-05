---
severity: Critical
category: Security configuration
resource: Virtual Network
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.VNET.UseNSGs.md
---

# Use NSGs on subnets

## SYNOPSIS

Subnets should have NSGs assigned.

## DESCRIPTION

Virtual network subnets should have network security groups (NSGs) assigned.

## RECOMMENDATION

The GatewaySubnet is a special named subnet which does not support NSGs.
For all other subnets define and assign a NSG.
