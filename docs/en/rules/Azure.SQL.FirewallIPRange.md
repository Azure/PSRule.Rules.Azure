---
severity: Important
pillar: Security
category: SE:06 Network controls
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.FirewallIPRange/
ms-content-id: a25b1927-f04c-4a6a-8a3d-42d59d4722ff
---

# SQL Database service firewall exposes a broad range of addresses

## SYNOPSIS

Each IP address in the permitted IP list is allowed network access to any databases hosted on the same logical server.

## DESCRIPTION

The Azure SQL database service firewall is an important security control, that help restrict network access to data.
Access to a database still requires an identity with permissions to read the data in addition to network access.
Combining network and identity controls together further harden your environment against,
use of compromised identities during lateral traversal and misuse of credentials.

Typically the number of IP address rules permitted through the firewall is minimal,
with management connectivity from on-premises and cloud application connectivity the most common.
Excessive access from many IP addresses may indicate weak network security controls.

## RECOMMENDATION

Consider reducing the size or count of the IP ranges in the Firewall rules so that the total Allowed IPs are less than (10).

## NOTES

This rule assesses the combined IP addresses from each Allowed IP firewall entry to check that the total allowed addresses is less than (10).

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Azure SQL Database and Azure Synapse IP firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql)
- [Create and manage IP firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql#create-and-manage-ip-firewall-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/firewallrules)
