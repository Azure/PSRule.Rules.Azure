---
severity: Awareness
pillar: Operational Excellence
category: Deployment
resource: Network Interface
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NIC.UniqueDns/
---

# NICs with custom DNS settings

## SYNOPSIS

Network interfaces (NICs) should inherit DNS from virtual networks.

## DESCRIPTION

By default Virtual machine (VM) NICs automatically use a DNS configuration inherited from the virtual network they connect to.
Optionally, DNS servers can be overridden on a per NIC basis with a custom configuration.

Using network interfaces with individual DNS server settings may increase management overhead and complexity.

## RECOMMENDATION

Consider updating NIC DNS server settings to inherit from virtual network.

## LINKS

- [Change DNS servers](https://learn.microsoft.com/azure/virtual-network/virtual-network-network-interface?tabs=azure-portal#change-dns-servers)
