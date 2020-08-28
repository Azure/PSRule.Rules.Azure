---
severity: Important
pillar: Reliability
category: Availability
resource: Virtual Network
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VNET.LocalDNS.md
---

# Use local DNS servers

## SYNOPSIS

Virtual networks (VNETs) should use Azure local DNS servers.

## DESCRIPTION

Virtual networks allow one or more custom DNS servers to be specified that are inherited by connected services such as virtual machines.

When configuring custom DNS server IP addresses, these servers must be accessible for name resolution to occur.
Connectivity between services may be impacted if DNS server IP addresses are temporarily or permanently unavailable.

## RECOMMENDATION

Consider deploying redundant DNS services within a connected Azure VNET.

Where possibly consider deploying Azure Private DNS Zones, a platform-as-a-service (PaaS) DNS service for VNETs.
Alternatively consider deploying redundant virtual machines (VMs) or network virtual appliances (NVA) to host DNS within Azure.
