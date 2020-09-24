---
severity: Important
pillar: Security
category: Network security and containment
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.FirewallIPRange.md
ms-content-id: a25b1927-f04c-4a6a-8a3d-42d59d4722ff
---

# Limit SQL logical server firewall rule range

## SYNOPSIS

Determine if there is an excessive number of permitted IP addresses.

## DESCRIPTION

Typically the number of IP address rules permitted through the firewall is minimal, with management connectivity from on-premises and cloud application connectivity the most common.

## RECOMMENDATION

SQL Server has greater then ten (10) public IP addresses that are permitted network access.
Some rules may not be needed or can be reduced.

## LINKS

- [Azure SQL Database and Azure Synapse IP firewall rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure)
- [Create and manage IP firewall rules](https://docs.microsoft.com/azure/azure-sql/database/firewall-configure#create-and-manage-ip-firewall-rules)
