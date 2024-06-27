---
severity: Important
pillar: Security
category: SE:06 Network controls
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.FirewallIPRange/
ms-content-id: a25b1927-f04c-4a6a-8a3d-42d59d4722ff
---

# Limit SQL logical server firewall rule range

## SYNOPSIS

Determine if there is an excessive number of permitted IP addresses set in the allowed IP list (CIDR range).

## DESCRIPTION

Typically the number of IP address rules permitted through the firewall is minimal, with management connectivity from
on-premises and cloud application connectivity the most common. This rule assesses the combined IP addresses from each
Allowed IP firewall entry to check that the total allowed addresses is less than (10).

## RECOMMENDATION

Reduce the size or count of the IP ranges set in the Firewall rules so that the total Allowed IPs are less than (10).

## Example

## LINKS

- [Azure SQL Database and Azure Synapse IP firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql)
- [Create and manage IP firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql#create-and-manage-ip-firewall-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/firewallrules)
