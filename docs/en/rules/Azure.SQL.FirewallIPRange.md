---
severity: Important
pillar: Security
category: Network security and containment
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.FirewallIPRange/
ms-content-id: a25b1927-f04c-4a6a-8a3d-42d59d4722ff
---

# Limit SQL logical server firewall rule range

## SYNOPSIS

Determine if there is an excessive number of permitted IP addresses set in the allowed IP list (CIDR range).

## DESCRIPTION

Typically the number of IP address rules permitted through the firewall is minimal, with management connectivity from
on-premises and cloud application connectivity the most common. This rule checks the IP addresses IP list
(CIDR range of each IP provided) set in the SQL allowed address isn't excess.

## RECOMMENDATION

Reduce the size of the IP ranges set in the each allowed IP rule to less than (10) per entry (less than a /27).

## Example

## LINKS

- [Azure SQL Database and Azure Synapse IP firewall rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure)
- [Create and manage IP firewall rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure#create-and-manage-ip-firewall-rules)
