---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.DNSLabel/
---

# Use valid Public IP DNS labels

## SYNOPSIS

Public IP domain name labels should meet naming requirements.

## DESCRIPTION

When configuring Azure Public IP addresses domain name labels must meet naming requirements.
The requirements for Public IP domain name labels are:

- Between 3 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Start with a letter.
- End a letter or number.
- Domain name labels must be globally unique within a region.

## RECOMMENDATION

Consider using domain name labels that meet Public IP naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if Public IP domain name labels are unique.

## LINKS

- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
