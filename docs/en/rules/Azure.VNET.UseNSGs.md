---
severity: Critical
pillar: Security
category: Network security and containment
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.UseNSGs/
---

# Use NSGs on subnets

## SYNOPSIS

Subnets should have NSGs assigned.

## DESCRIPTION

Virtual network subnets should have a network security group (NSG) assigned.
NSGs are a basic stateful firewall that can be assigned to a virtual machine network interface or a subnets.

## RECOMMENDATION

The GatewaySubnet and AzureFirewallSubnet are special named subnets which does not support NSGs.
For all other subnets, define and assign a NSG.

## LINKS

- [Network Security Best Practices](https://docs.microsoft.com/azure/security/fundamentals/network-best-practices#logically-segment-subnets)
- [Azure Firewall FAQ](https://docs.microsoft.com/azure/firewall/firewall-faq#are-network-security-groups-nsgs-supported-on-the-azure-firewall-subnet)
