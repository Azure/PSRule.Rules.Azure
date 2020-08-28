---
severity: Important
pillar: Security
category: Network security and containment
resource: SQL Database
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SQL.AllowAzureAccess.md
ms-content-id: 30a551f6-54e0-4e51-b068-f9695d891a89
---

# Azure.SQL.AllowAzureAccess

## SYNOPSIS

Determine if access from Azure services is required.

## DESCRIPTION

Allow access to Azure services, permits any Azure service including other Azure customers, network based access to databases on the same logical SQL Server.
Network access can also be allowed/ blocked on individual databases, which takes precedence over this option.

If network based access is permitted, authentication is still required.

Enabling access from Azure Services is useful in certain cases for on demand PaaS workloads where configuring a stable IP address is not possible.
For example Azure Functions, Container Instances and Logic Apps.

## RECOMMENDATION

Where a stable IP addresses are able to be configured, configure IP or virtual network based firewall rules instead of using Allow access to Azure services.

Determine if access from Azure services is required for the services connecting to the hosted databases.
