---
severity: Critical
pillar: Security
category: Network security and containment
resource: Firewall
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Firewall.Mode.md
---

# Configure deny on threat intel

## SYNOPSIS

Deny high confidence malicious IP addresses and domains.

## DESCRIPTION

Threat intelligence-based filtering can optionally be enabled on Azure Firewall.
When enabled, Azure Firewall alerts and deny traffic to/ from known malicious IP addresses and domains.

By default, Azure Firewall alerts on triggered threat intelligence rules.

## RECOMMENDATION

Consider configuring Azure Firewall to alert and deny IP addresses and domains detected as malicious.

## LINKS

- [Azure Firewall threat intelligence-based filtering](https://docs.microsoft.com/en-us/azure/firewall/threat-intel)
