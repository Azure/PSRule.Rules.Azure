---
severity: Single point of failure
category: Reliability
resource: Virtual Network
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.VNET.SingleDNS.md
---

# Use redundant DNS servers

## SYNOPSIS

VNETs should have at least two DNS servers assigned.

## DESCRIPTION

Virtual networks (VNETs) should have at least two (2) DNS servers assigned.

## RECOMMENDATION

Virtual networks should have at least two (2) DNS servers set when not using Azure-provided DNS.

Using a single DNS server may indicate a single point of failure where the DNS IP address is not load balanced.
